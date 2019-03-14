workflow "Main Workflow" {
  on = "push"
  resolves = ["Test"]
}

action "Build" {
  uses = "actions/action-builder/docker@master"
  runs = "make"
  args = "build"
}

action "Test" {
  needs = ["Build"]
  uses = "actions/action-builder/docker@master"
  runs = "make"
  args = "test"
}
