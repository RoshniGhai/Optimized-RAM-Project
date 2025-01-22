class environment:
generator gen: I
driver drv:
monitor non;
scoreboard scb:
mailbox gen2drv-new();
mailbox non2scb-new;
virtual intf vif;
function new(virtual intf vifir
this,vifovif;
gen-new(genzdrv)
drv-new (gen2drv, vif)1
mon-new(mon2sch, vif);
scb-new(mon2scb)1
endfunction
             
task run
	fork
  	  gen.write();
      drv.run();
      mon.run();
      scb.run();
join
  
  #50 fork
gen.read();
drv.run(); 
mon.run();
scb.run();
join
#50 fork 
  gen.read_write(); 
  drv.run(); 
  mon.run(); 
  scb.run();
  
#10 drv.run();
#20 mon.run();
#20 scb.run();
join
endtask
endclass