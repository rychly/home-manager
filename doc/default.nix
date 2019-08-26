{ pkgs }:

let

  lib = pkgs.lib;

  nmdSrc = pkgs.fetchFromGitLab {
    owner = "rycee";
    repo = "nmd";
    rev = "ddfb3861fd8aa7c59fc68e912f178270b13a672e";
    sha256 = "02p136j10hj8q5qyp2y83qryk8zql7kwxcf23wzdlcskfv1b4ih2";
  };

  nmd = import nmdSrc { inherit pkgs; };

  hmModulesDocs = nmd.buildModulesDocs {
    modules = import ../modules/modules.nix { inherit lib pkgs; };
    moduleRootPaths = [ ./.. ];
    mkModuleUrl = path:
      "https://github.com/rycee/home-manager/blob/master/${path}#blob-path";
    channelName = "home-manager";
    docBook.id = "home-manager-options";
  };

  docs = nmd.buildDocBookDocs {
    pathName = "home-manager";
    modulesDocs = [ hmModulesDocs ];
    documentsDirectory = ./.;
    chunkToc = ''
      <toc>
        <d:tocentry xmlns:d="http://docbook.org/ns/docbook" linkend="book-home-manager-manual"><?dbhtml filename="index.html"?>
          <d:tocentry linkend="ch-options"><?dbhtml filename="options.html"?></d:tocentry>
          <d:tocentry linkend="ch-tools"><?dbhtml filename="tools.html"?></d:tocentry>
          <d:tocentry linkend="ch-release-notes"><?dbhtml filename="release-notes.html"?></d:tocentry>
        </d:tocentry>
      </toc>
    '';
  };

in

{

  options = {
    json = hmModulesDocs.json.override {
      path = "share/doc/home-manager/options.json";
    };
  };

  manPages = docs.manPages;

  manual = {
    inherit (docs) html htmlOpenTool;
  };

}
