{ config, pkgs, ... }:

{
  programs.wofi = {
    enable = true;

    settings = {
      width = 500;
      height = 400;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 24;
      columns = 1;
    };

    style = ''
      /* Nord Color Palette */
      @define-color nord0 #2e3440;
      @define-color nord1 #3b4252;
      @define-color nord2 #434c5e;
      @define-color nord3 #4c566a;
      @define-color nord4 #d8dee9;
      @define-color nord5 #e5e9f0;
      @define-color nord6 #eceff4;
      @define-color nord8 #88c0d0;
      @define-color nord11 #bf616a;

      * {
        font-family: "JetBrainsMono Nerd Font", "Inter", sans-serif;
        font-size: 14px;
      }

      window {
        background-color: alpha(@nord0, 0.95);
        border: 2px solid @nord3;
        border-radius: 12px;
      }

      #input {
        margin: 12px;
        padding: 12px 16px;
        border: none;
        border-radius: 8px;
        background-color: @nord1;
        color: @nord4;
        font-size: 15px;
      }

      #input:focus {
        border: 1px solid @nord8;
        outline: none;
      }

      #input image {
        color: @nord3;
      }

      #outer-box {
        margin: 0 12px 12px 12px;
      }

      #scroll {
        margin: 0;
        border: none;
      }

      #inner-box {
        background-color: transparent;
      }

      #entry {
        padding: 10px 12px;
        margin: 2px 0;
        border-radius: 8px;
        background-color: transparent;
      }

      #entry:selected {
        background-color: @nord2;
      }

      #entry:selected #text {
        color: @nord8;
      }

      #text {
        color: @nord4;
        margin-left: 8px;
      }

      #img {
        margin-right: 8px;
      }
    '';
  };
}
