#!/usr/bin/env ruby

# Simple blockchain implementation 

# Part 1 - Building a Blockchain
require 'digest'
require 'json'
require 'sinatra'

class Blockchain
    @chain = Array.new

    def initialize
        create_block(1, '0') # Create genesis block with proof = 1, prev_hash = 0
    end

    def create_block(proof, prev_hash)
        block = {
            :index => @chain.length +1,
            :timestamp => Time.now,
            :proof => proof,
            :prev_hash => prev_hash
        }
        @chain.push(block)
        return block
    end

    def get_prev_block()
        return @chain[-1]
    end

    def proof_of_work()
        new_proof = 1
        check_proof = false
        while !check_proof
            Digest::SHA256.hexdigest @chain[-1].to_s
        end
    end

    def hash(block)
        Digest::SHA256.hexdigest block.to_s
    end

    def is_chain_valid
        prev_block = @chain[0]
        block_index = 1
        while block_index < @chain.length
            block = @chain[block_index]
            if block[:prev_hash] != hash(prev_block) then
                return false
            end

            block_index += 1
        end
        return true
    end
end

blockchain = Blockchain.new

p blockchain


# Part 2 - Mining our Blockchain

# Creating a Web App
# Creating a Blockchain
# Mining a new block
# Getting the full Blockchain
# Checking if the Blockchain is valid
# Running the app