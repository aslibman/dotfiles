# Keybindings that mirror Windows/Linux conventions for apps excluded from
# the Karabiner windows-mode ruleset (e.g. VSCode, terminals).
[
  {
    key = "ctrl+c";
    command = "editor.action.clipboardCopyAction";
    when = "editorTextFocus";
  }
  {
    key = "ctrl+x";
    command = "editor.action.clipboardCutAction";
    when = "editorTextFocus";
  }
  {
    key = "ctrl+v";
    command = "editor.action.clipboardPasteAction";
    when = "editorTextFocus";
  }
  {
    key = "ctrl+z";
    command = "undo";
    when = "editorTextFocus";
  }
  {
    key = "ctrl+shift+z";
    command = "redo";
    when = "editorTextFocus";
  }
  {
    key = "ctrl+a";
    command = "editor.action.selectAll";
    when = "editorTextFocus";
  }
  {
    key = "ctrl+s";
    command = "workbench.action.files.save";
  }
  {
    key = "ctrl+f";
    command = "actions.find";
    when = "editorFocus";
  }
  {
    key = "ctrl+shift+f";
    command = "workbench.action.findInFiles";
    when = "editorFocus";
  }
  {
    key = "ctrl+w";
    command = "workbench.action.closeActiveEditor";
  }
  {
    key = "ctrl+left";
    command = "cursorWordLeft";
    when = "editorTextFocus";
  }
  {
    key = "ctrl+right";
    command = "cursorWordRight";
    when = "editorTextFocus";
  }
  {
    key = "ctrl+shift+left";
    command = "cursorWordLeftSelect";
    when = "editorTextFocus";
  }
  {
    key = "ctrl+shift+right";
    command = "cursorWordRightSelect";
    when = "editorTextFocus";
  }
  {
    key = "ctrl+tab";
    command = "workbench.action.nextEditor";
  }
  {
    key = "ctrl+shift+tab";
    command = "workbench.action.previousEditor";
  }
]
