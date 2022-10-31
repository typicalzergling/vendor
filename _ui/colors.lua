local _, Addon = ...
Addon.CommonUI = { Mixins = {} }
local TRANSPARENT = CreateColor(0,0,0,0)

Addon.CommonUI.Colors =
{
    TRANSPARENT = TRANSPARENT,

    TEXT = WHITE_FONT_COLOR,
    HOVER_TEXT = YELLOW_FONT_COLOR,
    SELECTED_TEXT = YELLOW_FONT_COLOR,

    SECONDARY_TEXT = CreateColor(1, 1, 1, .6),

    PLACEHOLDER_COLOR = CreateColor(1, 1, 1, .6),

    -- Selected Colors 
    SELECTED_BACKGROUND = CreateColor(1, 1, 0, 0.125),
    SELECTED_BORDER = CreateColor(1, 1, 0, 0.4),
    SELECTED_PRIMARY_TEXT = YELLOW_FONT_COLOR,

    HOVER_BACKGROUND = CreateColor(1, 1, 1, 0.125),
    HOVER_BORDER = CreateColor(1, 1, 0, 0.125),


    -- Dialog Colors
    DIALOG_BACK_COLOR = CreateColor(0.4, 0.45, 0.4, 0.5),
    DIALOG_CONTENT_BORDER_COLOR = CreateColor(0.5, 0.5, 0.5, 0.25),
    DIALOG_CONTENT_BACKGROUND_COLOR = CreateColor(.1, .1, .1, 1),
    DIALOG_CAPTION_BACK_COLOR = CreateColor(0.3, 0.35, 0.35, 1),
    DIALOG_CAPTION_COLOR = CreateColor(1, 1, 0, 1),
    DIALOG_BORDER_COLOR = CreateColor(.5, .5, .5, .8),

    -- Edit Colors
    EDIT_BORDER = CreateColor(1, 1, 1, .4),
    EDIT_BACK = CreateColor(.8, .8, .8, .1),
    EDIT_HIGHLIGHT = CreateColor(1, 1, 1, .7),
    EDIT_DISABLED = CreateColor(.5, .5, .5, .5),
    EDIT_TEXT = WHITE_FONT_COLOR,
    
    -- Button colors
    BUTTON_BORDER = CreateColor(1, 1, 1, .75),
    BUTTON_BACK = CreateColor(0, 0, 0, .4),
    BUTTON_TEXT = CreateColor(1, 1, 1, .75),
    BUTTON_HOVER_BACK = CreateColor(1, 1, 0, .3),
    BUTTON_HOVER_TEXT = CreateColor(1, 1, 0, 1),
    BUTTON_HOVER_BORDER = CreateColor(1, 1, 0, 1),
    BUTTON_DISABLED_BACK = TRANSPARENT,
    BUTTON_DISABLED_BORDER = CreateColor(0.5, 0.5, 0.5, .5),
    BUTTON_DISABLED_TEXT = CreateColor(0.5, 0.5, 0.5, .5),

    LIST_BORDER = CreateColor(1, 1, 1, .5),
    LIST_BACK = TRANSPARENT,
    LIST_EMPTY_TEXT = CreateColor(.5, .5, .5, .5),

    -- Checkbox
    CHECKBOX_BORDER = CreateColor(1, 1, 1, .5),
    CHECKBOX_LABEL = WHITE_FONT_COLOR,
    CHECKBOX_HELP = CreateColor(1, 1, 1, .6),
    CHECKBOX_BACK = TRANSPARENT,
    CHECKBOX_HOVER_BORDER = YELLOW_FONT_COLOR,
    CHECKBOX_HOVER_BACK = CreateColor(1, 1, 1, 0.05),
    CHECKBOX_CHECK = CreateColor(1, 1, 0, 0.6),
    CHECKBOX_DISABLED = CreateColor(1, 1, 1, .5),

}