workflow "Push Workflow" {
  on = "push"
  resolves = ["Test"]
}

workflow "Release Workflow" {
  on = "release"
  resolves = ["Release"]
}

action "Build" {
  uses = "actions/action-builder/docker@master"
  runs = "make"
  args = "build"
  env = {
    IMAGE = "daimor/isc-tar"
  }
}

action "Test" {
  needs = ["Build"]
  uses = "docker://daimor/isc-tar"
  runs = "/tests_entrypoint.sh"
}

action "Artifacts" {
  needs = ["Build"]
  uses = "docker://daimor/isc-tar"
  runs = "/build_artifacts.sh"
}

action "Release" {
  needs = ["Artifacts"]
  uses = "JasonEtco/upload-to-release@master"
  secrets = ["GITHUB_TOKEN"]
  args = "out/zUtils.FileBinaryTar.xml text/xml"
}