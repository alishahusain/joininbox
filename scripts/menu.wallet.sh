#!/bin/bash

# WALLET menu options

source /home/joinmarket/joinin.conf
source /home/joinmarket/_functions.sh

checkRPCwallet

# BASIC MENU INFO
HEIGHT=12
WIDTH=52
CHOICE_HEIGHT=21
TITLE="Wallet management options"
BACKTITLE="Wallet management options"
MENU=""
OPTIONS=()

# Basic Options
OPTIONS+=(\
  GEN "Generate a new wallet" \
  HISTORY "Show all past transactions" \
  IMPORT "Copy wallet(s) from a remote node"\
  RECOVER "Restore a wallet from the seed" \
  UNLOCK "Remove the lockfiles"
  RESCAN "Rescan the Bitcoin Core wallet"
)

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

case $CHOICE in

  GEN)
      clear
      echo ""
      . /home/joinmarket/joinmarket-clientserver/jmvenv/bin/activate
      if [ "${RPCoverTor}" = "on" ]; then 
        torify python /home/joinmarket/joinmarket-clientserver/scripts/wallet-tool.py generate
      else
        python /home/joinmarket/joinmarket-clientserver/scripts/wallet-tool.py generate
      fi
      echo
      echo "Press ENTER to return to the menu"
      read key
      ;;
  HISTORY)
      # wallet
      chooseWallet
      /home/joinmarket/start.script.sh wallet-tool $(cat $wallet) "history -v 4"
      echo
      echo "Press ENTER to return to the menu"
      read key
      ;;
  IMPORT) 
      /home/joinmarket/info.importwallet.sh
      echo "Returning to the menu..."
      sleep 1
      /home/joinmarket/menu.sh
      ;;
  RECOVER)
      clear
      echo
      . /home/joinmarket/joinmarket-clientserver/jmvenv/bin/activate
      if [ "${RPCoverTor}" = "on" ];then 
        torify python /home/joinmarket/joinmarket-clientserver/scripts/wallet-tool.py recover
      else
        python /home/joinmarket/joinmarket-clientserver/scripts/wallet-tool.py recover
      fi
      echo ""
      echo "Press ENTER to return to the menu"
      read key
      ;;
  UNLOCK)
      echo "Removing the wallet lockfiles with the command:"
      echo "rm ~/.joinmarket/wallets/.*.lock"
      rm ~/.joinmarket/wallets/.*.lock
      # for old version <v0.6.3
      rm ~/.joinmarket/wallets/*.lock 2>/dev/null
      echo ""
      echo "Press ENTER to return to the menu"
      read key
      ;;
  RESCAN)
      checkRPCwallet
      echo
      echo "# Input the blockheight to scan from (first SegWit block: 477120):"
      read blockheight
      customRPC "# Rescan wallet in bitcoind" "rescanblockchain" "$blockheight"
      echo
      echo "# Monitor the progress in the logs of the connected bitcoind"
      echo
      echo "Press ENTER to return to the menu"
      read key
      ;;
esac