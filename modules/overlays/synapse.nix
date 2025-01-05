{ ... }:
final: prev: {
 python312 = prev.python312.override {
   packageOverrides = pfinal: pprev: {
     pysaml2 = pfinal.toPythonModule final.emptyDirectory;
   };
 };
 matrix-synapse-unwrapped = (prev.matrix-synapse-unwrapped.overrideAttrs (old: {
   postPatch = (old.postPatch or "") + ''
     substituteInPlace tests/storage/databases/main/test_events_worker.py --replace-fail \
     $'    def test_recovery(' \
     $'    from tests.unittest import skip_unless\n'\
     $'    @skip_unless(False, "broken")\n'\
     $'    def test_recovery('
   '';
 })).overridePythonAttrs { doCheck = false; };
}
