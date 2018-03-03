import zui.Zui;

@:access(zui.Zui)
class CustomUI {
    static var selectedHandle:Handle = null;

	public static function hierarchy(ui:Zui, handle:Handle, text:String, hasChildren:Bool=false): Bool {
		if (!ui.isVisible(ui.ELEMENT_H())) { ui.endElement(); return handle.selected; }
        if(handle.changed) handle.changed = false;
		if (ui.getReleased()) {
            //handle.selected = !handle.selected;
            //handle.selected = true;
            selectedHandle = handle;

            handle.changed = true;
        }

        handle.selected = selectedHandle == handle;

        if(handle.selected) {
			ui.g.color = ui.t.ACCENT_SELECT_COL;
			ui.g.fillRect(ui._x, ui._y, ui._w, ui.ELEMENT_H());
        }

		if(hasChildren) ui.drawArrow(handle.selected);

		ui.g.color = ui.t.PANEL_TEXT_COL; // Title
		ui.g.opacity = 1.0;
		ui.drawString(ui.g, text, ui.titleOffsetX, 0);

		ui.endElement();

		return handle.selected;
	}
}