import 'dart:convert';
import 'package:http/http.dart' as http;


class AIService {
  static const String apiKey = "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"; 
  static const String baseUrl = "https://api.openai.com/v1/chat/completions";
  
  static String? lastUserMessage ;
  
  static String? lastAIReply ;

  static Future<String> getReply(String message) async {
    try{
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "system",
              "content": "You are afriendly and professional medical assistant.If the user greets you (hi, hello), respond warmly like a human conversation.Ask how you can help before giving medical advice.Understand symtoms and provide clear, safe and helpful suggestions.Do not give final diagnosis.Always recommend appropriatr doctor types.Be polite, natural and human-like."
            },
            {
              "role": "user",
              "content":"Previous: ${lastUserMessage ?? ""}"

            },
            {
              "role": "assistant",
              "content":lastAIReply ??""
            },
            {
              "role": "user",
             "content": message
            }
          ]
        }),
      );
      if (response.statusCode == 200){
        final data =jsonDecode(response.body);

        return data ["choices"][0]["message"]["content"].trim();
        
      }
      
      return localReply(message);

      } catch (e) {
      return localReply(message);
      
    }}

  /*static Future<dynamic> getSpecialty(String message) async {}

  static String localReply(String text) {}
    }

  static Future<dynamic> getSpecialty(String message) async {}
  }*/

  static String localReply(String message) {
    message = message.toLowerCase();

    if (message.contains("hi") || message.contains("hello")) {
      return "Hello, how can I help you today?";
    }

    if (message.contains("tooth") ||
        message.contains("teeth") ||
        message.contains("gum")) {
      return "You may have a dental issue. Please consult a Dentist.";
    }

    if (message.contains("skin") ||
        message.contains("rash") ||
        message.contains("acne")) {
      return "This seems like a skin issue. A Dermatologist can help.";
    }

    if (message.contains("fever") ||
        message.contains("cold") ||
        message.contains("cough") ||
        message.contains("pain")) {
      return "It looks like a general illness. Rest well and consult a General doctor if needed.";
    }

    if (message.contains("headache") ||
        message.contains("dizzy")) {
      return "You may need to consult a Neurologist.";
    }

    if (message.contains("eye") ||
        message.contains("vision")) {
      return "This may be an eye problem. Visit an Ophthalmologist.";
    }

    if (message.contains("chest") ||
        message.contains("heart")) {
      return "Chest issues can be serious. Please consult a Cardiologist.";
    }

    return "Please explain your symptoms more clearly.";
  }

 
  static Future<String> getSpecialty(String message) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "system",
              "content":
                  "Return only one doctor type: Dentist, Cardiologist, Dermatologist, Neurologist, General."
            },
            {"role": "user", "content": message}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["choices"][0]["message"]["content"].trim();
      }

      return localSpecialty(message);
    } catch (e) {
      return localSpecialty(message);
    }
  }

  static String localSpecialty(String message) {
    message = message.toLowerCase();

    if (message.contains("tooth")) return "Dentist";
    if (message.contains("heart") || message.contains("chest")) return "Cardiologist";
    if (message.contains("skin")) return "Dermatologist";
    if (message.contains("head")) return "Neurologist";

    return "General";
  }
}
