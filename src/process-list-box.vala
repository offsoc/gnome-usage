using Gee;

namespace Usage
{
    public class ProcessListBox : Gtk.Box
    {
        private Gee.ArrayList<ProcessRow> rows;
        HashTable<string, ProcessRow> process_rows_table;

        public ProcessListBox()
        {
            orientation = Gtk.Orientation.VERTICAL;
            rows = new Gee.ArrayList<ProcessRow>();
            process_rows_table = new HashTable<string, ProcessRow>(str_hash, str_equal);

            Timeout.add((GLib.Application.get_default() as Application).settings.list_update_interval, update);
            Timeout.add((GLib.Application.get_default() as Application).settings.first_update_interval, () => //on first load
            {
                update();
                return false;
            });
        }

        public bool update()
        {
            foreach(ProcessRow row in rows)
                row.pre_update();

            var duplicates = new HashSet<string>();

            foreach(unowned Process process in (GLib.Application.get_default() as Application).monitor.get_processes())
            {
                if(duplicates.contains(process.cmdline))
                {
                    unowned ProcessRow row = process_rows_table[process.cmdline];

                    if(!row.is_in_subrows(process.pid))
                    {
                        if((int) process.cpu_load > 0)
                            row.add_sub_row(process.pid, (int) process.cpu_load, process.cmdline);
                    }
                    else
                    {
                        if((int) process.cpu_load > 0)
                            row.update_sub_row(process.pid, (int) process.cpu_load);
                    }
                }
                else
                {
                    if(!(process.cmdline in process_rows_table))
                    {
                        if((int) process.cpu_load > 0)
                        {
                            ProcessRow row = new ProcessRow(process.pid, (int) process.cpu_load, process.cmdline);
                            rows.add(row);
                            process_rows_table.insert (process.cmdline, row);
                            duplicates.add(process.cmdline);
                        }
                    }
                    else
                    {
                        if((int) process.cpu_load > 0)
                        {
                            unowned ProcessRow row = process_rows_table[process.cmdline];
                            row.set_value(process.pid, (int) process.cpu_load);
                            duplicates.add(process.cmdline);
                        }
                    }
                }
            }

            sort();

            this.forall ((element) => this.remove (element)); //clear box

            foreach(unowned ProcessRow row in process_rows_table.get_values())
            {
                row.post_update();
                if(row.get_alive() == false)
                {
                    process_rows_table.remove(row.get_cmdline());
                    rows.remove(row);
                }
            }

            for(int i = 0; i < rows.size; i++)
                if(rows[i].get_alive())
                    this.add(rows[i]);

            return true;
        }

        public void sort()
        {
            rows.sort((a, b) => {
                return(b as ProcessRow).get_value() - ( a as ProcessRow).get_value();
            });
        }
    }
}