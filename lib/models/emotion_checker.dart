class emotion {
  dynamic predictions;

  emotion({
    required this.predictions
  });

  factory emotion.fromJson (Map<String, dynamic> json){
    return emotion(
           predictions: json['predictions']);
  }
}