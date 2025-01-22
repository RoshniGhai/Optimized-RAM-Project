class monitor;
  transaction tx;
  mailbox mon2scb;

  virtual intf vif; // declare

  function new (mailbox mon2scb, virtual intf vif);
    this.mon2scb = mon2scb;
    this.vif = vif;
  endfunction

  task run();
    tx = new();
    #1;
    repeat (1) begin
      #1;
      tx.enb = vif.enb;
      tx.wr = vif.wr;
      tx.rd = vif.rd;
      tx.w_addr[4:0] = vif.w_addr[4:0];
      tx.w_data[7:0] = vif.w_data[7:0];
      tx.r_addr[4:0] = vif.r_addr[4:0];
      tx.r_data[7:0] = vif.r_data[7:0];
      #1;
      tx.display("COLLECTED IN MONITOR");
      mon2scb.put(tx);
    end
  endtask
endclass
