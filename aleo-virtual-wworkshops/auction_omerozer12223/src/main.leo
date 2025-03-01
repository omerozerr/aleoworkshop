// The 'auction_omerozer12223' program.
program auction_omerozer12223.aleo {
    record Bid {
        owner: address,
        bidder: address,
        amount: u64,
        is_winner: bool,
    }

    
    transition place_bid(bidder: address, amount: u64) -> Bid {
        assert_eq(self.caller, bidder);
        return Bid {
            owner: aleo1xupj2km9048avhkn7vwld4ewv2s4fmzp3zqmsp5p5gmmjfcgguysd29enp,
            bidder: bidder,
            amount: amount,
            is_winner: false,
        };
    }

    transition resolve(first: Bid, second: Bid) -> Bid {
        assert_eq(self.caller, aleo1xdfm5f7kuze2lz5nfma6tgq7h3klfl94zkk7yk9yf2dmy68muqxsn2djm0);
        if (first.amount >= second.amount) {
            return first;
        } else {
            return second;
        }
    }

  
    transition finish(bid: Bid) -> Bid {
       
        assert_eq(self.caller, aleo1xdfm5f7kuze2lz5nfma6tgq7h3klfl94zkk7yk9yf2dmy68muqxsn2djm0);
    
        return Bid {
            owner: bid.bidder,
            bidder: bid.bidder,
            amount: bid.amount,
            is_winner: true,
        };
    }
}
