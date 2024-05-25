// Generated by ReScript, PLEASE EDIT WITH CARE


function ellipsifyMiddle(inputString, precedingTrailingCharactersLength) {
  var stringLength = inputString.length;
  if (stringLength > (precedingTrailingCharactersLength << 1)) {
    return inputString.substring(0, precedingTrailingCharactersLength) + "..." + inputString.substring(Math.abs(stringLength - precedingTrailingCharactersLength | 0), stringLength);
  } else {
    return inputString;
  }
}

export {
  ellipsifyMiddle ,
}
/* No side effect */
