// This function takes a hex string list and converts it to a Pack-Bits encoded
// hex string.
// Example: (["00", "00", "00"]) => "fe00"
String packBitsEncode(List<String> hexStringList) {
  debugPrint("PACKBITS ENCODE: $hexStringList, ${hexStringList.length}");
  String encodedString = "";
  int reps = 1;
  String copyBuffer = "";
  for (int i = 0; i < hexStringList.length; i++) {
    if (i + 1 == hexStringList.length) {
      if (hexStringList[i - 1] == hexStringList[i]) {
        encodedString += (257 - reps).toRadixString(16).padRight(2, "0");
        encodedString += hexStringList[i];
        reps = 1;
      } else {
        copyBuffer += hexStringList[i];
        encodedString +=
            (copyBuffer.length ~/ 2 - 1).toRadixString(16).padLeft(2, "0");
        encodedString += copyBuffer;
        copyBuffer = "";
      }
      break;
    } else if (hexStringList[i] == hexStringList[i + 1]) {
      if (copyBuffer.isNotEmpty) {
        encodedString +=
            (copyBuffer.length ~/ 2 - 1).toRadixString(16).padLeft(2, "0");
        encodedString += copyBuffer;
        copyBuffer = "";
      }
      reps++;
      continue;
    }

    if (reps >= 2) {
      encodedString += (257 - reps).toRadixString(16).padRight(2, "0");
      encodedString += hexStringList[i];
      reps = 1;
    } else {
      copyBuffer += hexStringList[i];
    }
  }
  debugPrint("PACKBITS ENCODE: $encodedString");
  return encodedString;
}

// This function considers 0-127 as copy, 129-255 as repetition
// Decodes a Pack-Bits encoded Uint8List to a list of integers
// Example: ("cf00") => Array of fifty zeroes [0, 0, 0, ... 0]
// Example 2: ("fe00") => "fe" is 254 in decimal, so 255 - 254 = 1, so 1 zero
List<int> packbitsDecode(Uint8List encodedList) {
  List<int> decodedList = [];

  int leap = 1;
  for (int i = 0; i < encodedList.length; i += leap) {
    int converted = 0;
    int item = encodedList[i];
    if (item >= 0 && item <= 127) {
      // 0 - 127: Copy
      int cpy = item + 1;
      for (int j = 0; j < cpy; j++) {
        decodedList.add(encodedList[i + 1 + j]);
        converted++;
      }
      leap = 1 + converted;
    } else if (item >= 129 && item <= 255) {
      // 129 - 255: Repetition
      int rep = 257 - item;
      for (int j = 0; j < rep; j++) {
        decodedList.add(encodedList[i + 1]);
      }
      leap = 2;
    } else {
      leap = 2;
    }
  }
  debugPrint("PACKBITS DECODE: $decodedList, ${decodedList.length}");
  return decodedList;
}
