#!/usr/bin/env ruby
# frozen_string_literal: true

# Simple blockchain implementation

# Part 1 - Building a Blockchain
require 'digest'
require 'json'
require 'sinatra'
require 'puma'


class Blockchain
  @@chain = []
  def initialize
    create_block(1, '0') # Create genesis block with proof = 1, prev_hash = 0
  end

  def chain
    @@chain
  end

  def create_block(proof, prev_hash)
    block = {
      index: @@chain.length + 1,
      timestamp: Time.now,
      proof: proof,
      prev_hash: prev_hash
    }
    @@chain.append(block)
    block
  end

  def get_prev_block
    @@chain[-1]
  end

  def hash(block)
    Digest::SHA256.hexdigest(block.to_s)
  end

  def proof_of_work(pre_proof)
    new_proof = 1
    check_proof = false
    until check_proof
      hash = Digest::SHA256.hexdigest((new_proof.abs2 - pre_proof.abs2).to_s)
      if hash.slice(0, 4) == '0000'
        check_proof = true
      else
        new_proof += 1
      end
    end
    new_proof
  end

  def is_chain_valid
    prev_block = @@chain[0]
    block_index = 1
    while block_index < @@chain.length
      block = @@chain[block_index]
      return false if block[:prev_hash] != hash(prev_block)

      previous_proof = prev_block[:proof]
      proof = block[:proof]
      return false if Digest::SHA256.hexdigest((proof.abs2 - previous_proof.abs2).to_s).slice(0, 4) != '0000'

      prev_block = block
      block_index += 1
    end
    true
  end
end

# Part 2 - Mining our Blockchain

# Web App running with Sinatra and Puma
# Creating a Blockchain
blockchain = Blockchain.new

# Mining a new block
get '/mine_block' do
  previous_block = blockchain.get_prev_block
  previous_proof = previous_block[:proof]
  proof = blockchain.proof_of_work(previous_proof)
  previous_hash = blockchain.hash(previous_block)
  block = blockchain.create_block(proof, previous_hash)
  response = {
    'message': 'Congratulations, you just mined a block!',
    'index': block[:index],
    'timestamp': block[:timestamp],
    'proof': block[:proof],
    'previous_hash': block[:prev_hash]
  }
  return JSON.pretty_generate(response)
end

# Getting the full Blockchain
get '/get_chain' do
  response = {
    'chain': blockchain.chain,
    'length': blockchain.chain.length
  }
  return JSON.pretty_generate(response)
end

# Checking if the Blockchain is valid
get '/is_valid' do
  is_valid = blockchain.is_chain_valid
  response = if is_valid
               { 'message': 'All good. The Blockchain is valid.' }
             else
               { 'message': 'Houston, we have a problem. The Blockchain is not valid.' }
             end
  return JSON.pretty_generate(response)
end
