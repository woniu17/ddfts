#large flow: copy fresh data to workers 1MB-100MB
proc setup_large_flow {} {
        global ns
        global flow_file
        #flow count fc
        global fc
        #large flow count
        global lfc
        global lf_fid lf_src lf_dst lf_size lf_start lf_end
        global sg sc server
        global udr prr
        global lf_tcp lf_sink lf_ftp
        global sim_end_time
        #1. use $prr to generate large flow arrival time list
        #lat_list[]
        #set avg according CDF of time between background flows(@DCTCP)
        set avg 0.81
        set shape 55
        set r [prr $avg $shape]
        set lat_list(0) 0.01
        set i 0
        while { $lat_list($i) < $sim_end_time } {
            set ii $i
            incr i
            set lat_list($i) [expr [$r value] + $lat_list($ii)]
        }
        set lfc [expr $i]
        if { $lat_list($i) < $sim_end_time } {
            incr lfc
        }
        puts "large flow count: = $lfc"
        puts $flow_file "lfc:$lfc"

        #set large flow id
        for {set i 0} {$i < $lfc} {incr i 1} {
            set lf_fid($i) $fc
            incr fc 1
        }
        #set flow's src & dst
        set r1 [udr 0 $sg]
        set r2 [udr 0 $sc]
        for {set i 0} {$i < $lfc} {incr i 1} {
            set src "[expr int([$r1 value])],[expr int([$r2 value])]"
            set dst "[expr int([$r1 value])],[expr int([$r2 value])]"
            while {$src == $dst} {
                set dst "[expr int([$r1 value])],[expr int([$r2 value])]"
            }
            #puts "large flow $i, src: $src, dst:$dst"
            set lf_src($i) $src
            set lf_dst($i) $dst

        }

        #
        #set large flow's size
        #
        set r3 [udr 50000 100001]
        for {set i 0} {$i < $lfc} {incr i 1} {
            set lf_size($i) [expr int([$r3 value])*1000]
            #puts "flow $i, flow size: [expr $lf_size($i)]"
        }
        #
        #set flow's start //& end time
        #
        for {set i 0} {$i < $lfc} {incr i 1} {
            set lf_start($i) $lat_list($i)
        }
        #
        #set flow's Transmission Layer
        #
        for {set i 0} {$i < $lfc} {incr i 1} {
            set lf_tcp($i) [new Agent/TCP/FullTcp/Sack]
            set lf_sink($i) [new Agent/TCP/FullTcp/Sack]
            $lf_tcp($i) set d2tcp_d_ [expr 0.001]
	        $ns attach-agent $server($lf_src($i)) $lf_tcp($i)
	        $ns attach-agent $server($lf_dst($i)) $lf_sink($i)
	        $ns connect $lf_tcp($i) $lf_sink($i)
	        $lf_tcp($i) set fid_ $lf_fid($i)
            $lf_sink($i) listen
        }


        #
        #set flow's Application Layer
        #
        for {set i 0} {$i < $lfc} {incr i 1} {
            set lf_ftp($i) [new Application/FTP]
	        $lf_ftp($i) attach-agent $lf_tcp($i)
	        $lf_ftp($i) set type_ FTP
        }

        for {set i 0} {$i < $lfc} {incr i 1} {
            #puts "large flow $i start at $lf_start($i)"
            puts $flow_file "flow:$lf_fid($i)|ftype:l|deadline:-1|src:$lf_src($i)|dst:$lf_dst($i)|size:$lf_size($i)"
		    $ns at $lf_start($i) "$lf_ftp($i) send $lf_size($i)"
        }
}
