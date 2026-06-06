{ ... }:

{
  home.file = {
    ".config/zed/settings.json".source = ../../config/zed/settings.json;
    ".config/zed/keymap.json".source = ../../config/zed/keymap.json;
    ".config/zed/tasks.json".source = ../../config/zed/tasks.json;
    ".config/zed/snippets".source = ../../config/zed/snippets;
  };
}
