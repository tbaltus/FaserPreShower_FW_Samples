----------------------------------------------------------------------------------
-- Company.......: Université de Genève - DPNC
-- Author........: Terry Baltus
-- File..........: FPS_SlowControl.vhd
-- Description...: FaserPreShower: slow control package
-- Project Name..: FaserPreShower
-- Created.......: Jun 29, 2022
-- Version.......: -
--
-- Revision History:
-- Jun 29, 2022: file creation
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

package FPS_SlowControl is
   ------------------------------------------------------------------
   ---------------------- CONSTANTS ---------------------------------
   ------------------------------------------------------------------
   ---------------------- TYPES -------------------------------------
   ------------------------------------------------------------------
   ---------------------- FUNCTION ----------------------------------
   ------------------------------------------------------------------
   ---------------------- COMPONENT ---------------------------------
   --------------------------------------------------------------
   -- This entity produces a pulse (one clk cycle duration) every 
   -- x_prescaler clk cycles
   component FPS_SC_PRESCALER is
      Generic (
         x_reset_active       : std_logic := '0';
         x_prescaler          : integer
         );
      Port (
         x_nreset             : in std_logic;
         x_clk                : in std_logic;

         --FPS_SC_SPI interface-----
         x_pulse              : out std_logic
         );
   end component;

   
   --------------------------------------------------------------
   -- This entity serialises an 18 bit register using a SPI like
   -- protocol (CPOL = 0, CPHA = 0) at a freq = x_clk/(2*x_prescaler)
   -- then sends an acknowledge when done (one x_clk cycle duration)
   -- NEED : FPS_SC_PRESCALER
   component FPS_SC_SPI is
      Generic(
         x_reset_active       : std_logic := '0');
      Port (
         x_nreset             : in  std_logic;
         x_clk                : in  std_logic;

         --Feeder interface---------
         x_start              : in  std_logic; --must be valid until ack
         x_ack                : out std_logic; --Valid during 1 clk cycle
         x_reg                : in  std_logic_vector(19 downto 0); --must remain unchanged until ack
         
         --ASIC interface-----------
         x_clk_SPI            : out std_logic;
         x_CS                 : out std_logic;
         x_mosi               : out std_logic
         );
   end component; 

   
   --------------------------------------------------------------
   -- This entity feeds the spi driver when requested, configures the ASICS
   -- properly then sends an acknowledge to wrapper when done
   -- When sel = 10, one control command is sent : command number, chip address and data  
   -- are provided through a UserSetCfg
   -- When sel = 00, an entire super column is programmed : chip address and
   -- super column number are provided in the UserSetCfg.
   -- When sel = 01, Two super column (of the same number but of two different ASICs) are programmed :
   -- chip address and super column number are provided in the UserSetCfg. The two ASICs that are programmed are
   -- chip address(2 downto 1) & '0' and chip address(2 downto 1) & '1'.
   component FPS_SC_FEEDER is
      Generic(
         x_reset_active       : std_logic := '0'
      );
      Port (   
         x_nreset             : in  std_logic;
         x_clk                : in  std_logic;
         
         --Wrapper interface------
         x_start              : in  std_logic; --The wrapper keeps it valid until ack (required for dpram address multiplexing)
         x_ack                : out std_logic; --Valid for one clock cycle when finished
         x_err                : out std_logic; --Generates an error if when start, valid_word is different from 1
         x_valid_word         : in  std_logic; --Is valid if computer dpram image is equal to fpga dpram image (send, read, verify)
         
         --UserSetCfg interface---
         x_spi_cmd            : in  std_logic_vector(5 downto 0); --constant over data transfer
         x_spi_data_cmd       : in  std_logic_vector(7 downto 0); --constant over data transfer
         x_chip_address       : in  std_logic_vector(2 downto 0); --constant over data transfer
         x_super_column       : in  std_logic_vector(3 downto 0); --constant over data transfer
         x_sel                : in  std_logic_vector(1 downto 0); --"00" is dpram configuration, "10" is command configuration, "01" is dpram_cal configuration, constant over data transfer
         
         --DPRAM interface--------
         x_dpram_address      : out std_logic_vector(7 downto 0);
         x_dpram_q            : in  std_logic_vector(15 downto 0);
         
         --SPI interface----------
         x_spi_req            : out std_logic; --Valid until ack
         x_spi_reg            : out std_logic_vector(19 downto 0); --Must be kept valid until ack
         x_spi_ack            : in  std_logic --Valid for one clock cycle when finished
         );
   end component;
   

   -- This entity controls the reset
   -- When x_reset_sel = "00", the reset signal is connected to x_testpulse_nreset itself connected to a check box of the chip config out userSetCfg
   -- when x_reset_sel = "01", a reset that lasts 5 clock cycle is issues as soon as a request is received. Is issued an ack when finished
   -- when x_reset_sel = "10", a reset that lasts 9 clock cycle is issues as soon as a request is received. Is issued an ack when finished
   -- The reset is issued to the correct chip with x_chip_address
   component FPS_SC_RESET_PROBE_CARD is
   Generic(
         x_reset_active       : std_logic := '0');
   Port (
         x_nreset             : in  std_logic;
         x_ro_clk             : in  std_logic;
         --UserSetConfig interface---------
         x_start              : in  std_logic; --from userSet
         --Chip config out interface---------
         x_chip_address       : in std_logic_vector(2 downto 0);
         x_testpulse_nreset   : in std_logic;
         x_reset_sel          : in std_logic_vector(1 downto 0);
         --ASIC interface----------
         x_asic_nreset0       : out std_logic;
         x_asic_nreset1       : out std_logic;
         x_asic_nreset2       : out std_logic;
         x_asic_nreset3       : out std_logic;
         x_asic_nreset4       : out std_logic;
         x_asic_nreset5       : out std_logic);
   end component; 

   
   -- This entity allows the user to start feeders' processes in parrallel with a unique user set object. It allows also 
   -- the user to choose with feeder to start and which not to start. One error happening in any feeder is sufficient 
   -- to generate an error at the GPIO wrapper user set unique object side
   component FPS_SC_FEEDER_EN is
   Generic(
         x_reset_active       : std_logic := '0');
   Port (
         x_nreset             : in  std_logic;
         x_clk                : in  std_logic;
         --Interface with feeders---------
         x_feeder_req         : out std_logic_vector(5 downto 0);
         x_feeder_ack         : in  std_logic_vector(5 downto 0);
         x_feeder_err         : in  std_logic_vector(5 downto 0);
         --Wrapper interface
         x_req                : in  std_logic;
         x_ack                : out std_logic;
         x_err                : out std_logic;
         en                   : in  std_logic_vector(5 downto 0)
         ); -- connected to x_param_out(5 downto 0)
   end component;

   
   -- This is the DPRAM declaration for pixel programming
   component FPS_SC_256x16b_DPRAM IS
      PORT
      (
         clock                : in  std_logic  := '1';
         data                 : in  std_logic_vector (15 downto 0);
         rdaddress            : in  std_logic_vector (7 downto 0);
         wraddress            : in  std_logic_vector (7 downto 0);
         wren                 : in  std_logic  := '0';
         q                    : out std_logic_vector (15 downto 0)
      );
   END component;

   

   -- This is the slow control wrapper declaration
   component FPS_SC is
      Generic(
         x_reset_active       : std_logic := '0');
      Port (
         x_nreset             : in  std_logic;
         x_clk                : in  std_logic;
         --FPS_NRESET interface-------
         x_SC_nreset          : out std_logic_vector(35 downto 0);
        --ASIC interface-----------
         x_clk_spi_M0         : out std_logic;
         x_cs_M0              : out std_logic;
         x_mosi_M0            : out std_logic;
            
         x_clk_spi_M1         : out std_logic;
         x_cs_M1              : out std_logic;
         x_mosi_M1            : out std_logic;
         
         x_clk_spi_M2         : out std_logic;
         x_cs_M2              : out std_logic;
         x_mosi_M2            : out std_logic;
         
         x_clk_spi_M3         : out std_logic;
         x_cs_M3              : out std_logic;
         x_mosi_M3            : out std_logic;
         
         x_clk_spi_M4         : out std_logic;
         x_cs_M4              : out std_logic;
         x_mosi_M4            : out std_logic;
            
         x_clk_spi_M5         : out std_logic;
         x_cs_M5              : out std_logic;
         x_mosi_M5            : out std_logic;
         --GPIO wrapper interface-----
         x_user_set_req       : in  std_logic_vector(6 downto 0);
         x_user_set_ack       : out std_logic_vector(6 downto 0);
         x_user_set_err       : out std_logic_vector(6 downto 0);
         x_user_set_0_err_d   : out std_logic_vector(3 downto 0); --To multiplexe in the top level entity
         x_user_set_1_err_d   : out std_logic_vector(3 downto 0); --To multiplexe in the top level entity
         x_user_set_2_err_d   : out std_logic_vector(3 downto 0); --To multiplexe in the top level entity
         x_user_set_3_err_d   : out std_logic_vector(3 downto 0); --To multiplexe in the top level entity
         x_user_set_4_err_d   : out std_logic_vector(3 downto 0); --To multiplexe in the top level entity
         x_user_set_5_err_d   : out std_logic_vector(3 downto 0); --To multiplexe in the top level entity
         x_param_in           : in  std_logic_vector(15 downto 0);
         x_valid_word         : in  std_logic;
         x_dpram_data         : in  std_logic_vector(15 downto 0);
         x_dpram_wraddress    : in  std_logic_vector(10 downto 0);
         x_dpram_wren         : in  std_logic;
         x_dpram_rdaddress    : in  std_logic_vector(10 downto 0);
         x_dpram_q            : out std_logic_vector(15 downto 0)
         );
   end component; 
   
end FPS_SlowControl;

------------------------------------------------------------------
------------------------------------------------------------------