{ ... }:
final: prev: {
  webrtc-audio-processing_1 = prev.webrtc-audio-processing_1.overrideAttrs (o: {

    src = final.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "pulseaudio";
      repo = "webrtc-audio-processing";
      rev = "f89958d82420cc02c7d80cf8f365e6ed57546c92";
      hash = "sha256-RkH5+NiquGkX5g+PPvD2ZJ3GK+hT+NCbjgjfRTDfkbg=";
    };
  });
}
