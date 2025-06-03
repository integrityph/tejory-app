class Ethscan {
  String? status;
  String? message;
  List<Result>? result;

  Ethscan({this.status, this.message, this.result});

  Ethscan.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(new Result.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.result != null) {
      data['result'] = this.result!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Result {
  String? blockNumber;
  String? timeStamp;
  String? hash;
  String? nonce;
  String? blockHash;
  String? transactionIndex;
  String? from;
  String? to;
  String? value;
  String? gas;
  String? gasPrice;
  String? isError;
  String? txreceiptStatus;
  String? input;
  String? contractAddress;
  String? cumulativeGasUsed;
  String? gasUsed;
  String? confirmations;
  String? methodId;
  String? functionName;

  Result(
      {this.blockNumber,
      this.timeStamp,
      this.hash,
      this.nonce,
      this.blockHash,
      this.transactionIndex,
      this.from,
      this.to,
      this.value,
      this.gas,
      this.gasPrice,
      this.isError,
      this.txreceiptStatus,
      this.input,
      this.contractAddress,
      this.cumulativeGasUsed,
      this.gasUsed,
      this.confirmations,
      this.methodId,
      this.functionName});

  Result.fromJson(Map<String, dynamic> json) {
    blockNumber = json['blockNumber'];
    timeStamp = json['timeStamp'];
    hash = json['hash'];
    nonce = json['nonce'];
    blockHash = json['blockHash'];
    transactionIndex = json['transactionIndex'];
    from = json['from'];
    to = json['to'];
    value = json['value'];
    gas = json['gas'];
    gasPrice = json['gasPrice'];
    isError = json['isError'];
    txreceiptStatus = json['txreceipt_status'];
    input = json['input'];
    contractAddress = json['contractAddress'];
    cumulativeGasUsed = json['cumulativeGasUsed'];
    gasUsed = json['gasUsed'];
    confirmations = json['confirmations'];
    methodId = json['methodId'];
    functionName = json['functionName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['blockNumber'] = this.blockNumber;
    data['timeStamp'] = this.timeStamp;
    data['hash'] = this.hash;
    data['nonce'] = this.nonce;
    data['blockHash'] = this.blockHash;
    data['transactionIndex'] = this.transactionIndex;
    data['from'] = this.from;
    data['to'] = this.to;
    data['value'] = this.value;
    data['gas'] = this.gas;
    data['gasPrice'] = this.gasPrice;
    data['isError'] = this.isError;
    data['txreceipt_status'] = this.txreceiptStatus;
    data['input'] = this.input;
    data['contractAddress'] = this.contractAddress;
    data['cumulativeGasUsed'] = this.cumulativeGasUsed;
    data['gasUsed'] = this.gasUsed;
    data['confirmations'] = this.confirmations;
    data['methodId'] = this.methodId;
    data['functionName'] = this.functionName;
    return data;
  }
}
