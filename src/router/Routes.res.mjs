// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Core__Int from "@rescript/core/src/Core__Int.res.mjs";
import * as RescriptReactRouter from "@rescript/react/src/RescriptReactRouter.res.mjs";

function usePage() {
  var url = RescriptReactRouter.useUrl(undefined, undefined);
  var match = url.path;
  if (!match) {
    return "ChainSelect";
  }
  var restOfParams = match.tl;
  var chainId = Core__Int.fromString(match.hd, undefined);
  if (chainId === undefined) {
    return {
            TAG: "Error",
            _0: "The chainId is invalid, it must be an integer"
          };
  }
  if (!restOfParams) {
    return "Unknown";
  }
  switch (restOfParams.hd) {
    case "address" :
        var match$1 = restOfParams.tl;
        if (match$1 && !match$1.tl) {
          return {
                  TAG: "Address",
                  _0: chainId,
                  _1: match$1.hd,
                  _2: "Transactions"
                };
        } else {
          return "Unknown";
        }
    case "search" :
        if (restOfParams.tl) {
          return "Unknown";
        } else {
          return {
                  TAG: "Search",
                  _0: chainId
                };
        }
    default:
      return "Unknown";
  }
}

export {
  usePage ,
}
/* RescriptReactRouter Not a pure module */
