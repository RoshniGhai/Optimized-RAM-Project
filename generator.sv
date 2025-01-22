class generator
transaction tx;
mailbox gen2drv;
logic [4:0]w_addr;
function new (mailbox gen2drv); 
  
this.gen2drv=gen2drv;
endfunction
task write();
repeat (1) begin
tx=new();
//tx.randomize();
tx.wr=1;
tx.rd=0;
//tx.w_addr=16'h0010;
w_addr = tx.w_addr;
//tx.w_data=8b0000_1111;
gen2drv.put(tx);
tx.display("GENERATOR writing");
end
endtask
task read();
repeat (1) begin
  tx= new();
  //tx.randomize();
tx.wr=0;
tx.rd=1;
tx.r_addr=w_addr;
//tx.w_data=8'b5;
gen2drv.put (tx);
tx.display("GENERATOR reading");
end
endtask
task read_write();
repeat (1) begin
tx-new();
tx.randomize();
tx.wr=1;
tx.rd=0;
w_addr tx.w_addr;
gen2drv.put(tx);
  tx.display("GENERATOR reading_writing wr");
end
  
  #10 repeat(1) begin
    
    tx.wr=0;
    tx.rd=1;
    tx.r_addr=w_addr;
    //tx.w_data=8'b5;
    gen2drv.put(tx);
    tx.display("GENERATOR reading_writing rd");
  end
  
  
  
endtask
  
endclass