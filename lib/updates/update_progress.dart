class UpdateProgress {
  bool done;
  String message;
  Exception? ex;
  double progress;

  UpdateProgress(this.progress, {this.done=false, this.message="", this.ex});
}