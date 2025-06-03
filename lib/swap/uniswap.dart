import 'dart:typed_data';

import 'package:blockchain_utils/hex/hex.dart';
import 'package:tejory/coins/const.dart';
import 'package:tejory/coins/crypto_coin.dart';
import 'package:tejory/coins/erc-20.dart';
import 'package:tejory/coins/ether.dart';
import 'package:tejory/coins/ether_tx.dart';
import 'package:tejory/coins/tx.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/swap/abi.dart';
import 'package:tejory/swap/dex.dart';
import 'package:tejory/swap/exact_input_single_params.dart';
import 'package:tejory/swap/pool_key.dart';

class UniswapV4 implements DEX {
	// Commands
  static const int V4_SWAP = 0x10;
  static const int WRAP_ETH = 0x0b;
  static const int UNWRAP_WETH = 0x0c;
	// Actions
	static const int SWAP_EXACT_IN_SINGLE = 0x06;
	static const int SETTLE = 0x0b;
	static const int SETTLE_ALL = 0x0c;
	static const int TAKE = 0x0e;
	static const int TAKE_ALL = 0x0f;
  // Uniswap Params
  static const double tolerance = 0.005;
  // Permit2
  static const String PERMIT2_CONTRACT = "000000000022d473030f116ddee9f6b43ac78ba3";
  static const String UNIVERSAL_ROUTER_CONTRACT = "66a9893cc07d91d95644aedd05d03f95e1dba8af";
  static const String QUOTER_CONTRACT = "52f0e24d1c21c8a0cb1e5a5dd6198556bd9e1203";
  // MAX_VALUES
  static const String UINT160_MAX = "ffffffffffffffffffffffffffffffffffffffff";
  static const String UINT256_MAX = "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
  static const String UINT48_MAX = "ffffffffffff";

  // Ethereum
  static const int DEFAULT_TX_TYPE = 2;
  static const int SWAP_TX_GAS_UNITS = 300000;
  static const int ERC20_APPROVE_TX_GAS_UNITS = 75000;
  static const int PERMIT2_APPROVE_TX_GAS_UNITS = 75000;
  static const double PRIORITY_PERCENTAGE = 0.1;

  Future<bool> erc20Approved(ERC20 token) async {
    String myAddress = await token.getReceivingAddress();
    if (myAddress == "") {
      return false;
    }

    // allowance(address,address)
    String data = "0xdd62ed3e";
    // remove 0x
    data += hex.encode(Abi.encode(hex.decode(myAddress.substring(2))));
    data += hex.encode(Abi.encode(hex.decode(PERMIT2_CONTRACT)));
    String contractHash = "0x" + token.contractHash!;
    Map<String,dynamic> obj = {
      "to": contractHash,
      "data": data
    };
    print(data);
    var jObj = await token.rpcCall("eth_call", [obj]);
    if (jObj == null) {
      return false;
    }
    if (!jObj.containsKey("result")) {
      return false;
    }
    var result = (jObj["result"] as String).substring(2);
    BigInt limit = BigInt.parse(result.substring(0,64), radix: 16);
    if (limit == BigInt.zero) {
      return false;
    }
    
		return true;
  }

  Future<bool> permit2Approved(ERC20 token) async {
    String myAddress = await token.getReceivingAddress();
    if (myAddress == "") {
      return false;
    }
    
    // allowance(address,address,address)
    String data = "0x927da105";
    // remove 0x
    data += hex.encode(Abi.encode(hex.decode(myAddress.substring(2))));
    data += hex.encode(Abi.encode(hex.decode(token.contractHash!)));
    data += hex.encode(Abi.encode(hex.decode(UNIVERSAL_ROUTER_CONTRACT)));
    String contractHash = "0x" + PERMIT2_CONTRACT;
    Map<String,dynamic> obj = {
      "to": contractHash,
      "data": data
    };
    print(data);
    var jObj = await token.rpcCall("eth_call", [obj]);
    if (jObj == null) {
      return false;
    }
    if (!jObj.containsKey("result")) {
      return false;
    }
    var result = (jObj["result"] as String).substring(2);
    if (result.length <= 64 * 2) {
      return false;
    }
    BigInt limit = BigInt.parse(result.substring(0,64), radix: 16);
    if (limit == BigInt.zero) {
      return false;
    }
    BigInt deadline = BigInt.parse(result.substring(64,128), radix: 16);
    if (deadline.toInt() < 8640000000000) {
      if (DateTime.fromMillisecondsSinceEpoch(deadline.toInt() * 1000).isBefore(DateTime.now())) {
        return false;
      }
    }
    
		return true;
  }

  Future<bool> checkToken(CryptoCoin token) async {
    if (token is Ether) {
      return true;
    } else if (token is! ERC20) {
      return false;
    }

    bool result = await erc20Approved(token);
    if (!result) {
      return false;
    }
    return await permit2Approved(token);
  }

  Future<List<Tx>?> unlockToken(CryptoCoin token) async {
    if (token is Ether) {
      return [];
    } else if (token is! ERC20) {
      return null;
    }

    // get params
    int? gasPrice = await token.getFeeFromAPI();
    int? nonce = await token.getNonceFromAPI();

    if (gasPrice == null || nonce == null) {
      return null;
    }

    // approve Permit2 to spend the from the ERC-20 contract
    // approve(address _spender, uint256 _value)
    String data = "095ea7b3";
    data += hex.encode(Abi.encode(hex.decode(PERMIT2_CONTRACT)));
    data += UINT256_MAX;
    String? contractHash = token.contractHash;
    if (contractHash == null || contractHash.isEmpty) {
      return null;
    }
    
    List<Tx> txList = [];

    EtherTx tx1 = new EtherTx();
    tx1.type = DEFAULT_TX_TYPE;
    tx1.chainId = Constants.ETHER_CHAIN_ID;
    tx1.destination = Uint8List.fromList(hex.decode(contractHash));
    tx1.gasLimit = ERC20_APPROVE_TX_GAS_UNITS;
    tx1.maxFeePerGas = BigInt.from(gasPrice);
    tx1.maxPriorityFeePerGas = BigInt.from((tx1.maxFeePerGas.toDouble() * PRIORITY_PERCENTAGE).toInt());
    tx1.maxFeePerGas += tx1.maxPriorityFeePerGas;
    tx1.amount = BigInt.zero;
    tx1.data = Uint8List.fromList(hex.decode(data));
    tx1.nonce = nonce;

    // int eIndex;
    // var rawTx = tx1.getRawTX();
    // print("approve(address token,address spender,uint160 amount,uint48 expiration)");
    // for (int i=0; i<rawTx.length; i+=32){
    //   eIndex = (i+32 > rawTx.length) ? rawTx.length : i+32;
    //   print("$i: ${hex.encode(rawTx.sublist(i,eIndex))}");
    // }

    txList.add(tx1);

    // approve Universal Router V4 to spend from Permit2
    // approve(address token,address spender,uint160 amount,uint48 expiration)
    data = "87517c45";
    data += hex.encode(Abi.encode(hex.decode(token.contractHash!)));
    data += hex.encode(Abi.encode(hex.decode(UNIVERSAL_ROUTER_CONTRACT)));
    data += hex.encode(Abi.encode(hex.decode(UINT160_MAX)));
    data += hex.encode(Abi.encode(hex.decode(UINT48_MAX)));
    contractHash = PERMIT2_CONTRACT;
    
    EtherTx tx2 = new EtherTx();
    tx2.type = DEFAULT_TX_TYPE;
    tx2.chainId = Constants.ETHER_CHAIN_ID;
    tx2.destination = Uint8List.fromList(hex.decode(contractHash));
    tx2.gasLimit = PERMIT2_APPROVE_TX_GAS_UNITS;
    tx2.maxFeePerGas = BigInt.from(gasPrice);
    tx2.maxPriorityFeePerGas = BigInt.from((tx2.maxFeePerGas.toDouble() * PRIORITY_PERCENTAGE).toInt());
    tx2.maxFeePerGas += tx2.maxPriorityFeePerGas;
    tx2.amount = BigInt.zero;
    tx2.data = Uint8List.fromList(hex.decode(data));
    tx2.nonce = nonce + 1;

    // rawTx = tx2.getRawTX();
    // print("approve(address token,address spender,uint160 amount,uint48 expiration)");
    // for (int i=0; i<rawTx.length; i+=32){
    //   eIndex = (i+32 > rawTx.length) ? rawTx.length : i+32;
    //   print("$i: ${hex.encode(rawTx.sublist(i,eIndex))}");
    // }

    txList.add(tx2);

    return txList;
  }

  Uint8List? swapExactInputSingle(PoolKey key, BigInt amountIn, BigInt amountOut, DateTime deadline, {bool zeroForOne=true}) {
		// This is a translation of Solidity code found at:
		// https://docs.uniswap.org/contracts/v4/quickstart/swap

		/*
		// Encode the Universal Router command
    bytes memory commands = abi.encodePacked(uint8(Commands.V4_SWAP));
    bytes[] memory inputs = new bytes[](1);
		*/
    List<int> commands = Abi.encodePacked(V4_SWAP, 1);
		List<List<int>> inputs = [[]];

		/*
		// Encode V4Router actions
    bytes memory actions = abi.encodePacked(
        uint8(Actions.SWAP_EXACT_IN_SINGLE),
        uint8(Actions.SETTLE_ALL),
        uint8(Actions.TAKE_ALL)
    );
		*/
		List<int> actions = [];
		actions.addAll(Abi.encodePacked(SWAP_EXACT_IN_SINGLE, 1));
		actions.addAll(Abi.encodePacked(SETTLE_ALL, 1));
		actions.addAll(Abi.encodePacked(TAKE_ALL, 1));

		/*
		// Prepare parameters for each action
    bytes[] memory params = new bytes[](3);
    params[0] = abi.encode(
        IV4Router.ExactInputSingleParams({
            poolKey: key,
            zeroForOne: true,
            amountIn: amountIn,
            amountOutMinimum: minAmountOut,
            sqrtPriceLimitX96: uint160(0),
            hookData: bytes("")
        })
    );
		*/
    BigInt amountOutWithTolerance = BigInt.from((amountOut.toDouble() * (1-tolerance)).toInt());
		List<List<int>> params = [[],[],[]];
		params[0] = ExactInputSingleParams(key, zeroForOne, amountIn, amountOutWithTolerance, Uint8List(0)).encode();

		/*
		params[1] = abi.encode(key.currency0, amountIn);
		*/
		params[1].addAll(Abi.encode((zeroForOne)? key.currency0 : key.currency1));
		params[1].addAll(Abi.encode(amountIn));

		/*
		params[2] = abi.encode(key.currency1, minAmountOut);
		*/
		params[2].addAll(Abi.encode((zeroForOne)? key.currency1 : key.currency0));
		params[2].addAll(Abi.encode(amountOutWithTolerance));

		/*
		// Combine actions and params into inputs
    inputs[0] = abi.encode(actions, params);
		*/
		inputs[0].addAll(Abi.encode(0x40)); // actions (bytes)
		inputs[0].addAll(Abi.encode(0x80)); // params (bytes[])
		inputs[0].addAll(Abi.encode(actions.length)); // actions length  (This is the number of encoded actions)
		inputs[0].addAll(Abi.encode(actions, padLeft: false));
		inputs[0].addAll(Abi.encode(params.length)); // params length
		inputs[0].addAll(Abi.encode(params.length*32)); // params[0] (bytes)
		inputs[0].addAll(Abi.encode(params.length*32+params[0].length+32)); // params[1] (bytes)
		inputs[0].addAll(Abi.encode(params.length*32+params[0].length+params[1].length+32+32)); // params[2] (bytes)
		inputs[0].addAll(Abi.encode(params[0].length)); // params[0] length
		inputs[0].addAll(params[0]); // params[0] value
		inputs[0].addAll(Abi.encode(params[1].length)); // params[1] length
		inputs[0].addAll(params[1]); // params[1] value
		inputs[0].addAll(Abi.encode(params[2].length)); // params[2] length
		inputs[0].addAll(params[2]); // params[2] value

		List<int> executeCommand = hex.decode("3593564c");

		// this method does not actually execute the command but build it's data to be included in a transaction

		/*
		// Execute the swap
    router.execute(commands, inputs, deadline);
		*/
		
		List<int> result = executeCommand.toList();
		result.addAll(Abi.encode(0x60)); // commands (bytes)
		result.addAll(Abi.encode(0xa0)); // inputs (bytes[])
		result.addAll(Abi.encode(deadline.millisecondsSinceEpoch ~/ 1000)); // deadline
		result.addAll(Abi.encode(commands.length)); // commands length
		result.addAll(Abi.encode(commands, padLeft: false)); // commands value
		result.addAll(Abi.encode(inputs.length)); // inputs length
		result.addAll(Abi.encode(0x20)); // inputs[0] (bytes)
		result.addAll(Abi.encode(inputs[0].length)); // inputs[0] length
		result.addAll(inputs[0]); // inputs[0] value

    // result.add(0x0c);

		return Uint8List.fromList(result);
  }

	bool canSwap(CryptoCoin currency0, CryptoCoin currency1) {
		return true;
	}

	List<CryptoCoin> getSwapList(CryptoCoin currency) {
		return [];
	}

	Future<BigInt> swapRate(CryptoCoin currency0, CryptoCoin currency1, BigInt amountIn, {bool zeroForOne=true}) async {
    int fee = 500; // 500 = 0.05
		int tickSpacing = 10;
		PoolKey key = PoolKey(currency0, currency1, BigInt.from(fee), BigInt.from(tickSpacing), "");

    Ether eth = Singleton.assetList.assetListState.findAsset("ETH")!.coins[0] as Ether;
    // First we get the method hash for the following method:
    // quoteExactInputSingle() QuoteExactSingleParams memory params)
    //    external
    //    returns (uint256 amountOut, uint256 gasEstimate);
    // When this method is parsed for ABI encoding it would look like this:
    // quoteExactInputSingle(((address,address,uint24,int24,address),bool,uint128,bytes))
    // then we hash it using keccak and get the first 4 bytes which are 0xaa9d21cb
    String data = "0xaa9d21cb";
    data += hex.encode(key.encode());
    data += hex.encode(Abi.encode(zeroForOne));
    data += hex.encode(Abi.encode(amountIn));
    data += hex.encode(Abi.encode(""));
    String contractHash = "0x" + QUOTER_CONTRACT;
    Map<String,dynamic> obj = {
      "to": contractHash,
      "data": data
    };
    print(data);
    var jObj = await eth.rpcCall("eth_call", [obj]);
    if (jObj == null) {
      return BigInt.zero;
    }
    if (!jObj.containsKey("result")) {
      return BigInt.zero;
    }
    var result = (jObj["result"] as String).substring(2);
    BigInt rate = BigInt.parse(result.substring(0,64), radix: 16);
    print(rate);
    if (zeroForOne) {
      print(currency1.getDecimalAmount(rate));
    } else {
      print(currency0.getDecimalAmount(rate));
    }
    
		return rate;
	}

	Future<Tx?> swap(CryptoCoin currency0, CryptoCoin currency1, BigInt amountIn, BigInt minAmountOut) async {
    // check approvals
    if (currency0 is ERC20) {
      // setupApprovals(currency0);
    }
    
    // get LiquidityPool
    var pool = Singleton.swap.getLPForPair(currency0, currency1);
    if (pool == null) {
      return null;
    }
		PoolKey key = PoolKey(pool.currency0, pool.currency1, pool.fee, pool.tickSpacing, "");
    bool zeroForOne = pool.currency0.id == currency0.id;
		var data = swapExactInputSingle(key, amountIn, minAmountOut, DateTime.now().add(Duration(minutes: 30)), zeroForOne:zeroForOne);
    if (data == null) {
      return null;
    }
    // print("swap data ${hex.encode(data!.sublist(0,4))}");
    // int eIndex;
    // for (int i=4; i<data.length;i+=32) {
    //   eIndex = (i+32 < data.length) ? i+32 : data.length;
    //   print("$i ${hex.encode(data.sublist(i,eIndex))}");
    // }

    // get params
    int? gasPrice;
    int? nonce;
    if (currency0 is Ether) {
      gasPrice = await currency0.getFeeFromAPI();
      nonce = await currency0.getNonceFromAPI();
    } else if (currency0 is ERC20) {
      gasPrice = await currency0.getFeeFromAPI();
      nonce = await currency0.getNonceFromAPI();
    }

    if (gasPrice == null || nonce == null) {
      return null;
    }

    // To get a list of all contract addresses:
    // https://docs.uniswap.org/contracts/v4/deployments
    // What we use here in the Universal Router V4
    String contractHash = UNIVERSAL_ROUTER_CONTRACT;
    var tx = new EtherTx();
    tx.type = DEFAULT_TX_TYPE;
    tx.chainId = Constants.ETHER_CHAIN_ID;
    tx.destination = Uint8List.fromList(hex.decode(contractHash));
    tx.gasLimit = SWAP_TX_GAS_UNITS;
    tx.maxFeePerGas = BigInt.from(gasPrice);
    tx.maxPriorityFeePerGas = BigInt.from((tx.maxFeePerGas.toDouble() * PRIORITY_PERCENTAGE).toInt());
    tx.maxFeePerGas += tx.maxPriorityFeePerGas;
    tx.amount = (currency0 is Ether) ? amountIn : BigInt.zero;
    tx.data = Uint8List.fromList(data);
    tx.nonce = nonce;

    // var rawTx = tx.getRawTX();
    // for (int i=0; i<rawTx.length; i+=32){
    //   eIndex = (i+32 > rawTx.length) ? rawTx.length : i+32;
    //   print("$i: ${hex.encode(rawTx.sublist(i,eIndex))}");
    // }
		
		return tx;
	}
}