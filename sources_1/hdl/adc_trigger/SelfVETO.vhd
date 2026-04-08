library IEEE, mylib;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

use mylib.defAD9637Adc.all;
use mylib.defAdcTrigger.all;
use mylib.defSelfVETO.all;

entity SelfVETO is
  port(
    -- System --
    rst            : in  std_logic;
    clk            : in  std_logic;
    
    VetoPeriod     : std_logic_vector(kWidthVETO-1 downto 0);
    ActivePeriod   : std_logic_vector(kWidthDiscriPeriod-1 downto 0);
    
    -- Gate --
    GatePulseIn    : in  std_logic;
    GatePulseOut   : out std_logic
    );
end SelfVETO;

architecture RTL of SelfVETO is

  signal sr               : std_logic_vector(127 downto 0);
  signal pulse_in         : std_logic;
  signal delayed_pulse_in : std_logic;
  signal en_count         : std_logic;
  signal stop_count       : std_logic;
  signal veto_flag        : std_logic;
  signal veto_hold        : std_logic;
  signal pulse            : std_logic;

begin
  -- ==============================================================
  -- body
  -- ==============================================================
  
  GatePulseOut   <= pulse;
  pulse_in       <= GatePulseIn;
  
  u_gate_delay : process(clk)
  begin
    if(clk'event and clk = '1') then
      sr                <= sr(126 downto 0) & pulse_in;
      delayed_pulse_in  <= sr(to_integer(unsigned(ActivePeriod))-1);
    end if;
  end process;
  
  u_selfveto : process(clk)
    variable veto_count    : integer range 0 to kVetoCountRange;
  begin
    if(rst = '1') then
      veto_flag       <= '0';
      pulse           <= '0';
      
    elsif(clk'event and clk = '1') then 
      if(delayed_pulse_in = '1' or veto_flag = '1') then
        if(veto_count = conv_integer(VetoPeriod)) then
          veto_flag     <= '0';
          pulse         <= '0';
          veto_count    := 0;
        else
          veto_flag     <= '1';
          pulse         <= '0';
          veto_count    := veto_count + 1;
        end if;
      else
        pulse  <= GatePulseIn;
      end if;
    end if;
      
  end process;
  
end RTL;