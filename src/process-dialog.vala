using Posix;

namespace Usage
{
	public class ProcessDialog : Gtk.Dialog
	{
    	private pid_t pid;

    	public ProcessDialog(pid_t pid, string name)
    	{
    	    Object(use_header_bar: 1);
    	    set_transient_for((GLib.Application.get_default() as Application).window);
    	    set_position(Gtk.WindowPosition.CENTER);
    	    this.pid = pid;
    		this.title = name;
    		this.border_width = 5;
    		set_default_size (900, 350);
    		create_widgets();
    		connect_signals();
    	}

    	private void create_widgets()
    	{
    		Gtk.Box content = get_content_area() as Gtk.Box;
    		content.spacing = 10;

    		add_button (_("Stop"), Gtk.ResponseType.HELP).get_style_context().add_class ("destructive-action");
    	}

    	private void connect_signals()
    	{
    		this.response.connect (on_response);
    	}

    	private void on_response(Gtk.Dialog source, int response_id)
    	{
    		switch(response_id)
    		{
    		    case Gtk.ResponseType.HELP:
    		        kill_process(pid);
    		    	destroy();
    		    	break;
    		    case Gtk.ResponseType.CLOSE:
    		    	destroy();
    		    	break;
    		}
    	}

        private void kill_process(pid_t pid)
    	{
             Posix.kill (pid, Posix.SIGKILL);
    	}
    }
}