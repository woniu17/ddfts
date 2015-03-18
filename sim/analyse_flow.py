def analyse_flow(input_file_name):

    input_file = open(input_file_name, 'r')
    stime_dict = {} #start time for each flow
    etime_dict = {} #end time
    fsize_dict = {} #flow size
    drcnt_dict = {} #drop packet count for each flow
    src_dict = {}
    dst_dict = {}
    for line in input_file:
        #print len(line.strip().split(' '))
        action, time, frm, to, tp, pktsize, flag, flow_id, src, dst, seq_no, packet_id = line.strip().split(' ')
        time = float(time)
        pktsize = int(pktsize)

        if not flow_id in stime_dict:
            stime_dict[flow_id] = time
            etime_dict[flow_id] = time
            src_dict[flow_id] = src.split('.')[0]
            dst_dict[flow_id] = dst.split('.')[0]
        if not flow_id in fsize_dict:
            fsize_dict[flow_id] = 0
        if not flow_id in drcnt_dict:
            drcnt_dict[flow_id] = 0

        dst_node, dst_port = dst.split('.')
        #node 'to' receive and 'to' is dst_node and dst_node is flow[flow_id]'s dst
        if action == 'r' and to == dst_node and dst_dict[flow_id] == dst_node:
            etime_dict[flow_id] = time
            fsize_dict[flow_id] += pktsize
        elif action == 'd':
                drcnt_dict[flow_id] += 1

    input_file.close()

    id_list = sorted(stime_dict.keys(), lambda x,y: cmp(int(x),int(y)))
    if False:
            for flow_id in id_list:
                start = stime_dict[flow_id]
                end = etime_dict[flow_id]
                duration = end - start
                fsize = fsize_dict[flow_id]
                drcnt = drcnt_dict[flow_id]
                line = '%s %f %d %d\n' % (flow_id, duration, fsize, drcnt)
                if start < end:
                    #print 'flow %s: duration = %f, fsize=%d, drcnt = %d' % (flow_id, duration, fsize, drcnt)
                    #print line,
                    pass

    return (id_list, stime_dict, etime_dict, drcnt_dict, fsize_dict)