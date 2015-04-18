proc queue_trace { } {

    global ns
    global sc
    global trace_sampling_interval
    global queue_monitor queue_file
    set now [$ns now]
    set now_ [expr int([expr $now*1000000000])]
    for {set i 0} {$i < $sc} {incr i 1} {
          $queue_monitor($i) instvar parrivals_ pdepartures_ pdrops_ bdepartures_ pkts_ size_
          #now $queue($server) $queue_size_
          puts $queue_file "$now_ $i $pkts_ $size_"    
    }
    $ns at [expr $now + $trace_sampling_interval] "queue_trace"
}

proc tcp_trace { } {

    global ns
    global sc
    global trace_sampling_interval
    global tcp_file
    global qfc sfc lfc fc
    global qf_req_tcp qf_res_tcp
    global sf_req_tcp sf_res_tcp
    global lf_req_tcp lf_res_tcp

    set now [$ns now]
    set now_ [expr int([expr $now*1000000000])]

    #query flow
    set cwnd_sum 0
    #query flow only has ($sc - 1) "live" at most
    #qfid start with 1
    set offset [expr $qfc - ($sc - 1) + 1]
    if { $offset < 1 } {
        puts "warming: offset = $offset!!!! It should be greater than 0!!!"
        set offset 1
    }
    for {set i $offset} {$i <= $qfc} {incr i 1} {
        set req_cwnd  [$qf_req_tcp($i) set cwnd_]
        set res_cwnd  [$qf_res_tcp($i) set cwnd_]
        set cwnd [expr $req_cwnd + $res_cwnd]
        set cwnd_sum [expr $cwnd_sum + $cwnd]
    }
    puts -nonewline $tcp_file [format "q %9d %.2lf" $now_ $cwnd_sum]

    #large flow
    set cwnd_sum 0
    #lfid start with 0
    for {set i 0} {$i < $lfc} {incr i 1} {
        set req_cwnd  [$lf_req_tcp($i) set cwnd_]
        set req_alpha [$lf_req_tcp($i) set dctcp_alpha_]
        set res_cwnd  [$lf_res_tcp($i) set cwnd_]
        set cwnd [expr $req_cwnd + $res_cwnd]
        set cwnd_sum [expr $cwnd_sum + $cwnd]
    }
    puts -nonewline $tcp_file [format "l %9d %.2lf" $now_ $cwnd_sum]

    $ns at [expr $now + $trace_sampling_interval] "tcp_trace"
}
