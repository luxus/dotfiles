# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub }:
{
  ligature-el = {
    pname = "ligature-el";
    version = "d3426509cc5436a12484d91e48abd7b62429b7ef";
    src = fetchgit {
      url = "https://github.com/mickeynp/ligature.el";
      rev = "d3426509cc5436a12484d91e48abd7b62429b7ef";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-baFDkfQLM2MYW2QhMpPnOMSfsLlcp9fO5xfyioZzOqg=";
    };
  };
  nix = {
    pname = "nix";
    version = "2e606e87c44a8dc42664f8938eac1d4b63047dd6";
    src = fetchFromGitHub ({
      owner = "nixos";
      repo = "nix";
      rev = "2e606e87c44a8dc42664f8938eac1d4b63047dd6";
      fetchSubmodules = false;
      sha256 = "sha256-i37NAJjKr7NBkS4I8M3u5ZjRDtdVsUdyw6vMkAduALI=";
    });
  };
}
