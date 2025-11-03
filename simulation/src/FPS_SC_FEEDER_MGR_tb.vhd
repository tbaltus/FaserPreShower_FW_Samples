library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.Numeric_STD.all;

-- do tst_FPS_SC_FEEDER_MGR_tb.do

-- ENTITY ----------------------------------------------------

entity FPS_SC_FEEDER_MGR_tb is
end FPS_SC_FEEDER_MGR_tb;

-- ARCHITECTURE  ---------------------------------------------
Architecture rtl of FPS_SC_FEEDER_MGR_tb is
-- Constants -------------------------------------------------

-- Types -----------------------------------------------------		

-- aliases----------------------------------------------------
	
-- Signals ---------------------------------------------------

	signal x_nreset 	: std_logic;
	signal x_clk 		: std_logic;
	signal x_start 		: std_logic;
	signal x_ack 		: std_logic;
	signal x_err 		: std_logic;
	signal x_req 		: std_logic;
	signal en			: std_logic;
	signal x_code 		: std_logic_vector(1 downto 0);


  ----------------------------------------------
  -- Procedure

-- Components ------------------------------------------------
component FPS_SC_FEEDER_MGR is
	Generic(
		x_reset_active : std_logic := '0');
	Port (
		x_nreset	: in  std_logic;
		x_clk 		: in  std_logic;

		--Feeder interface---------
		x_start 	: out  std_logic; --must be valid until ack
		x_ack 		: in std_logic;   --Valid for one clock cycle when feeder done
		x_err 		: in std_logic;   --Valid for one clock cycle if error when feeder done
		
		--Wrapper interface-----------
		x_req 		: in std_logic;
   		en 			: in std_logic;

		--FPS_SC_GUI_MGMT interface-----------
   		x_code 		: out std_logic_vector(1 downto 0));
end component;

begin
	-------------------------------------------------------------------------------
	-- components instanciation
	-------------------------------------------------------------------------------

	FPS_SC_FEEDER_MGR_DUT : FPS_SC_FEEDER_MGR
	generic map(
		x_reset_active 	=> '0')
	port map (
		x_nreset	=> x_nreset,
		x_clk 		=> x_clk,
		x_start 	=> x_start,
		x_ack 		=> x_ack,
		x_err 		=> x_err,
		x_req 		=> x_req,
   		en 			=> en,
   		x_code 		=> x_code);

	-------------------------------------------------------------------------------
	-- COMBINATORIAL --------------------------------------------------------------
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-- PROCESS --------------------------------------------------------------------
	-------------------------------------------------------------------------------

	p_clk : process  --50MHz
	begin
		x_clk <= '1';
		wait for 10 ns;
		x_clk <= '0';
		wait for 10 ns;
	end process;

	p_testbench : PROCESS
	begin

		x_nreset <= '0';
		x_req 	<= '0';
		x_ack <= '0';
		x_err <= '0';
		en <= '0';

		wait for 50 ns;
		report "starting test ... " & time'image(now);
		x_nreset <= '1';

		en <= '1';
		x_req 		<= '1';

		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		x_ack <= '1';

		wait until x_clk = '1';
		x_ack <= '0';

		wait until x_clk = '1';
		assert (x_code = "10") report "Error x_code (expect 0b10" & "; read 0b" & to_string(x_code) & ")" severity failure;

		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		x_req 	<= '0';

		wait until x_clk = '1';
		x_req 	<= '1';

		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		x_ack <= '1';
		x_err <= '1';

		wait until x_clk = '1';
		x_ack <= '0';
		x_err <= '0';

		wait until x_clk = '1';
		assert (x_code = "01") report "Error x_code (expect 0b01" & "; read 0b" & to_string(x_code) & ")" severity failure;

		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		x_req 	<= '0';

		wait until x_clk = '1';

		en <= '0';
		x_req 		<= '1';

		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		x_ack <= '1';
		wait until x_clk = '1';
		x_ack <= '0';
		wait until x_clk = '1';


		x_req 		<= '0';

		wait until x_clk = '1';


		
		----------------------------------------------------
		report "TEST SUCCESSFULL ... " & time'image(now);
		---------------------------------------------------
		wait; -- will wait forever
	end process;

end rtl;