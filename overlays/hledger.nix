final: prev: {
  haskellPackages = prev.haskellPackages.extend (hfinal: hprev: {
    hledger = hfinal.callCabal2nixWithOptions "hledger" final.hledger-src "--subpath=hledger" {};
    hledger-lib = hfinal.callCabal2nixWithOptions "hledger-lib" final.hledger-src "--subpath=hledger-lib" {};
    hledger-ui = hfinal.callCabal2nixWithOptions "hledger-ui" final.hledger-src "--subpath=hledger-ui" {};
    hledger-web = hfinal.callCabal2nixWithOptions "hledger-web" final.hledger-src "--subpath=hledger-web" {};
  });
}
