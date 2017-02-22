using Gtk;

namespace Usage {

    public class GraphBlockRow : Gtk.Box
    {
        Gtk.Label value_label;
        GraphBlockType type;

        public GraphBlockRow(GraphBlockType type, string label_text, string css_class)
        {
            Object(orientation: Gtk.Orientation.HORIZONTAL);
            var color_rectangle = new ColorRectangle.new_from_css(css_class);
            var label = new Gtk.Label(label_text);
            label.margin = 5;
            label.ellipsize = Pango.EllipsizeMode.END;
            label.max_width_chars = 15;
            value_label = new Gtk.Label("0 %");
            value_label.width_chars = 5;
            value_label.width_chars = 5;
            value_label.xalign = 1;
            this.pack_start(color_rectangle, false, false);
            this.pack_start(label, false, true, 5);
            this.pack_end(value_label, false, true, 10);
            this.type = type;
        }

        public void update(uint64 value)
        {
            switch(type)
            {
                case GraphBlockType.PROCESSOR:
                    value_label.set_text(value.to_string() + " %");
                    break;
                case GraphBlockType.MEMORY:
                    value_label.set_text(Utils.format_size_values(value));
                    break;
                case GraphBlockType.NETWORK:
                    value_label.set_text(Utils.format_size_speed_values(value));
                    break;
            }
        }
    }
}
