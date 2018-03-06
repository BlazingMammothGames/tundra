import zui.Zui;

@:access(zui.Zui)
class CustomZUI {
    static var selectedHierarchy:Handle = null;

	private static function getArrowInitialHover(ui:Zui):Bool {
		return ui.inputEnabled &&
			ui.inputInitialX >= ui._windowX + ui._x && ui.inputInitialX < (ui._windowX + ui._x + ui.arrowOffsetX + ui.ARROW_SIZE()) &&
			ui.inputInitialY >= ui._windowY + ui._y && ui.inputInitialY < (ui._windowY + ui._y + ui.ELEMENT_H());
	}

	private static function getArrowHover(ui:Zui):Bool {
		ui.isHovered = ui.inputEnabled &&
			ui.inputX >= ui._windowX + ui._x && ui.inputX < (ui._windowX + ui._x + ui.arrowOffsetX + ui.ARROW_SIZE()) &&
			ui.inputY >= ui._windowY + ui._y && ui.inputY < (ui._windowY + ui._y + ui.ELEMENT_H());
		return ui.isHovered;
	}

	private static function getArrowReleased(ui:Zui): Bool { // Input selection
		ui.isReleased = ui.inputEnabled && ui.inputReleased && getArrowHover(ui) && getArrowInitialHover(ui);
		return ui.isReleased;
	}

	public static function hierarchy(ui:Zui, handle:Handle, text:String, hasChildren:Bool=false):{selected:Bool, expanded:Bool} {
		if (!ui.isVisible(ui.ELEMENT_H())) { ui.endElement(); return {selected: handle.selected, expanded: handle.value > 0.0}; }
		if(getArrowReleased(ui)) {
			handle.value = 1.0 - handle.value;
			handle.changed = true;
		}
		else if(ui.getReleased()) {
			if(selectedHierarchy != null) {
				selectedHierarchy.selected = false;
				selectedHierarchy.changed = true;
			}
			selectedHierarchy = null;
			handle.selected = !handle.selected;
			if(handle.selected) selectedHierarchy = handle;
			handle.changed = true;
		}

		if(selectedHierarchy == handle && handle.selected) {
			ui.g.color = ui.t.ACCENT_SELECT_COL;
			ui.g.fillRect(ui._x, ui._y, ui._w, ui.ELEMENT_H());
		}
		else {
			//ui.g.color = ui.t.PANEL_BG_COL;
		}
		

		if(hasChildren) ui.drawArrow(handle.value > 0.0);

		ui.g.color = ui.t.PANEL_TEXT_COL; // Title
		ui.g.opacity = 1.0;
		ui.drawString(ui.g, text, ui.titleOffsetX, 0);

		ui.endElement();

		return {selected: handle.selected, expanded: handle.value > 0.0};
	}
}