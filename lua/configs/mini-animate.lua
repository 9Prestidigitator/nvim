local animate = require "mini.animate"

animate.setup {
  -- Cursor path
  cursor = {
    -- Whether to enable this animation
    enable = false,

    -- Timing of animation (how steps will progress in time)
    -- timing = --<function: implements linear total 250ms animation duration>,

    -- Path generator for visualized cursor movement
    -- path = --<function: implements shortest line path no longer than 1000>,
  },

  -- Vertical scroll
  scroll = {
    -- Whether to enable this animation
    enable = true,

    -- Timing of animation (how steps will progress in time)
    -- timing = --<function: implements linear total 250ms animation duration>,
    timing = animate.gen_timing.linear { easing = "in", duration = 30, unit = "total" },

    -- Subscroll generator based on total scroll
    -- subscroll = --<function: implements equal scroll with at most 60 steps>,
  },

  -- Window resize
  resize = {
    -- Whether to enable this animation
    enable = true,

    -- Timing of animation (how steps will progress in time)
    -- timing = --<function: implements linear total 250ms animation duration>,
    timing = animate.gen_timing.linear { easing = "in", duration = 20, unit = "total" },

    -- Subresize generator for all steps of resize animations
    -- subresize = --<function: implements equal linear steps>,
  },

  -- Window open
  open = {
    -- Whether to enable this animation
    enable = false,

    -- Timing of animation (how steps will progress in time)
    -- timing = --<function: implements linear total 250ms animation duration>,
    timing = animate.gen_timing.quadratic { easing = "out", duration = 13, unit = "total" },

    -- Floating window config generator visualizing specific window
    -- winconfig = --<function: implements static window for 25 steps>,
    winconfig = animate.gen_winconfig.wipe { direction = "from_edge" },

    -- 'winblend' (window transparency) generator for floating window
    -- winblend = --<function: implements equal linear steps from 80 to 100>,
    winblend = animate.gen_winblend.linear { from = 80, to = 100 },
  },

  -- Window close
  close = {
    -- Whether to enable this animation
    enable = false,

    -- Timing of animation (how steps will progress in time)
    -- timing = --<function: implements linear total 250ms animation duration>,
    -- timing = 100,

    -- Floating window config generator visualizing specific window
    -- winconfig = --<function: implements static window for 25 steps>,

    -- 'winblend' (window transparency) generator for floating window
    -- winblend = --<function: implements equal linear steps from 80 to 100>,
  },
}
