library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.Numeric_STD.all;

-- do tst_FPS_SC_FEEDER_EN_tb.do

-- ENTITY ----------------------------------------------------

entity FPS_SC_FEEDER_EN_tb is
end FPS_SC_FEEDER_EN_tb;

-- ARCHITECTURE  ---------------------------------------------
Architecture rtl of FPS_SC_FEEDER_EN_tb is
-- Constants -------------------------------------------------

-- Types -----------------------------------------------------		

-- aliases----------------------------------------------------
	
-- Signals ---------------------------------------------------

	signal x_nreset 		: std_logic;
	signal x_clk 			: std_logic;
	signal x_feeder_req 	: std_logic_vector(5 downto 0);
	signal x_feeder_ack 	: std_logic_vector(5 downto 0);
	signal x_feeder_err 	: std_logic_vector(5 downto 0);
	signal x_req 			: std_logic;
	signal x_ack 			: std_logic;
	signal x_err 			: std_logic;
	signal en				: std_logic_vector(5 downto 0);


  ----------------------------------------------
  -- Procedure

-- Components ------------------------------------------------
component FPS_SC_FEEDER_EN is
	Generic(
		x_reset_active : std_logic := '0');
	Port (
		x_nreset	: in  std_logic;
		x_clk 		: in  std_logic;

		--Interface with feeders---------
		x_feeder_req : out std_logic_vector(5 downto 0);
		x_feeder_ack : in  std_logic_vector(5 downto 0);
		x_feeder_err : in  std_logic_vector(5 downto 0);

		--Wrapper interface
		x_req 		: in  std_logic;
		x_ack 		: out std_logic;
		x_err 		: out std_logic;
		en 			: in  std_logic_vector(5 downto 0));
end component;	

begin
	-------------------------------------------------------------------------------
	-- components instanciation
	-------------------------------------------------------------------------------

	FPS_SC_FEEDER_EN_DUT : FPS_SC_FEEDER_EN
	generic map(
		x_reset_active 	=> '0')
	port map (
		x_nreset 		=> x_nreset,
		x_clk 			=> x_clk,
		x_feeder_req 	=> x_feeder_req,
		x_feeder_ack 	=> x_feeder_ack,
		x_feeder_err 	=> x_feeder_err,
		x_req 			=> x_req,
		x_ack 			=> x_ack,
		x_err 			=> x_err,
		en 				=> en);

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
		x_nreset 		<= '0';
		x_feeder_ack 	<= "000000";
		x_feeder_err 	<= "000000";
		x_req 			<= '0';
		en 				<= "000000";

		wait for 50 ns;
		report "starting test ... " & time'image(now);
		x_nreset <= '1';

		wait until x_clk = '1';
		en 	<= "111111";
		wait until x_clk = '1';
		x_req 			<= '1';
		
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';

		x_feeder_ack(0) <= '1';
		wait until x_clk = '1';
		x_feeder_ack(0) <= '0';

		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';

		x_feeder_ack(4 downto 1) <= "1111";
		wait until x_clk = '1';
		x_feeder_ack(4 downto 1) <= "0000";

		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';

		x_feeder_ack(5) <= '1';
		wait until x_clk = '1';
		x_feeder_ack(5) <= '0';

		wait until x_ack = '1';
		assert (x_err = '0') report "Error x_err (expect 0b0" & "; read 0b" & to_string(x_err) & ")" severity failure;
		wait until x_clk = '1';
		x_req 			<= '0';

		--------------------------

		wait until x_clk = '1';
		en 	<= "000001";
		wait until x_clk = '1';
		x_req 			<= '1';
		
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';

		x_feeder_ack(0) <= '1';
		assert (x_err = '0') report "Error x_err (expect 0b0" & "; read 0b" & to_string(x_err) & ")" severity failure;
		wait until x_clk = '1';
		x_feeder_ack(0) <= '0';


		wait until x_ack = '1';
		wait until x_clk = '1';
		x_req 			<= '0';

		--------------------------

		wait until x_clk = '1';
		en 	<= "000000";
		wait until x_clk = '1';
		x_req 			<= '1';


		wait until x_ack = '1';
		assert (x_err = '0') report "Error x_err (expect 0b0" & "; read 0b" & to_string(x_err) & ")" severity failure;
		wait until x_clk = '1';
		x_req 			<= '0';

		--------------------------

		wait until x_clk = '1';
		en 	<= "000001";
		wait until x_clk = '1';
		x_req 			<= '1';
		
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';

		x_feeder_ack(0) <= '1';
		x_feeder_err(0) <= '1';
		wait until x_clk = '1';
		x_feeder_ack(0) <= '0';
		x_feeder_err(0) <= '0';


		wait until x_ack = '1';
		assert (x_err = '1') report "Error x_err (expect 0b1" & "; read 0b" & to_string(x_err) & ")" severity failure;
		wait until x_clk = '1';
		x_req 			<= '0';

		---------------------------

		wait until x_clk = '1';
		en 	<= "111011";
		wait until x_clk = '1';
		x_req 			<= '1';
		
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';

		x_feeder_ack(0) <= '1';
		wait until x_clk = '1';
		x_feeder_ack(0) <= '0';

		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';

		x_feeder_ack(5 downto 3) <= "111";
		x_feeder_err(5 downto 3) <= "111";
		wait until x_clk = '1';
		x_feeder_ack(5 downto 3) <= "000";
		x_feeder_err(5 downto 3) <= "000";

		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';

		x_feeder_ack(1) <= '1';
		wait until x_clk = '1';
		x_feeder_ack(1) <= '0';

		wait until x_ack = '1';
		assert (x_err = '1') report "Error x_err (expect 0b1" & "; read 0b" & to_string(x_err) & ")" severity failure;
		wait until x_clk = '1';
		x_req 			<= '0';

		---------------------------

		wait until x_clk = '1';
		en 	<= "111011";
		wait until x_clk = '1';
		x_req 			<= '1';
		
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';

		x_feeder_ack(0) <= '1';
		x_feeder_err(0) <= '1';
		wait until x_clk = '1';
		x_feeder_ack(0) <= '0';
		x_feeder_err(0) <= '0';

		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';

		x_feeder_ack(5 downto 3) <= "111";
		wait until x_clk = '1';
		x_feeder_ack(5 downto 3) <= "000";

		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';

		x_feeder_ack(1) <= '1';
		wait until x_clk = '1';
		x_feeder_ack(1) <= '0';

		wait until x_ack = '1';
		assert (x_err = '1') report "Error x_err (expect 0b1" & "; read 0b" & to_string(x_err) & ")" severity failure;
		wait until x_clk = '1';
		x_req 			<= '0';

		----------------------------------------------------
		report "TEST SUCCESSFULL ... " & time'image(now);
		---------------------------------------------------
		wait; -- will wait forever
	end process;

end rtl;