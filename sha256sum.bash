#!/usr/bin/env bash
set -o errexit


sha256sum.bash() {
	# Credit to Josh Junon (josh@junon.me) <github.com/qix-> for the original implementation of producing a SHA256 checksums with BASH: https://gist.github.com/Qix-/eaa6b90f4f50a9aefc66c4f871e8f1e0
	local -a k=($((0x428a2f98)) $((0x71374491)) $((0xb5c0fbcf)) $((0xe9b5dba5)) $((0x3956c25b)) $((0x59f111f1)) $((0x923f82a4)) $((0xab1c5ed5)) \
		 $((0xd807aa98)) $((0x12835b01)) $((0x243185be)) $((0x550c7dc3)) $((0x72be5d74)) $((0x80deb1fe)) $((0x9bdc06a7)) $((0xc19bf174)) \
		 $((0xe49b69c1)) $((0xefbe4786)) $((0x0fc19dc6)) $((0x240ca1cc)) $((0x2de92c6f)) $((0x4a7484aa)) $((0x5cb0a9dc)) $((0x76f988da)) \
		 $((0x983e5152)) $((0xa831c66d)) $((0xb00327c8)) $((0xbf597fc7)) $((0xc6e00bf3)) $((0xd5a79147)) $((0x06ca6351)) $((0x14292967)) \
		 $((0x27b70a85)) $((0x2e1b2138)) $((0x4d2c6dfc)) $((0x53380d13)) $((0x650a7354)) $((0x766a0abb)) $((0x81c2c92e)) $((0x92722c85)) \
		 $((0xa2bfe8a1)) $((0xa81a664b)) $((0xc24b8b70)) $((0xc76c51a3)) $((0xd192e819)) $((0xd6990624)) $((0xf40e3585)) $((0x106aa070)) \
		 $((0x19a4c116)) $((0x1e376c08)) $((0x2748774c)) $((0x34b0bcb5)) $((0x391c0cb3)) $((0x4ed8aa4a)) $((0x5b9cca4f)) $((0x682e6ff3)) \
		 $((0x748f82ee)) $((0x78a5636f)) $((0x84c87814)) $((0x8cc70208)) $((0x90befffa)) $((0xa4506ceb)) $((0xbef9a3f7)) $((0xc67178f2)))
	
	local -a data=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
	local -a rhash=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
	local -i datalen=0
	local -a bitlen=(0 0)
	local -a state=($((0x6a09e667)) $((0xbb67ae85)) $((0x3c6ef372)) $((0xa54ff53a)) $((0x510e527f)) $((0x9b05688c)) $((0x1f83d9ab)) $((0x5be0cd19)))
	local rotright__out rotright__a rotright__b rotright__c ch__out maj__out ep0__out ep1__out sig0__out sig1__out b32__out not32__out

	function dbl_int_add {
		if [[ ${bitlen[0]} > $(( 0xffffffff - ${1} )) ]]; then
			bitlen[1]=$(( bitlen[1] + 1 ))
		fi
		bitlen[0]=$(( bitlen[0] + ${1} ))
	}
	
	function rotright {
		rotright__out=$(( ((${1} >> ${2}) | (${1} << (32 - ${2}))) & 0xFFFFFFFF ))
	}
	function ch {
		not32 ${1}
		ch__out=$(( (${1} & ${2}) ^ (not32__out & ${3}) ))
	}
	function maj {
		maj__out=$(( (${1} & ${2}) ^ (${1} & ${3}) ^ (${2} & ${3}) ))
	}
	function ep0 {
		rotright ${1} 2; rotright__a=$rotright__out
		rotright ${1} 13; rotright__b=$rotright__out
		rotright ${1} 22; rotright__c=$rotright__out
		ep0__out=$(( rotright__a ^ rotright__b ^ rotright__c ))
	}
	function ep1 {
		rotright ${1} 6; rotright__a=$rotright__out
		rotright ${1} 11; rotright__b=$rotright__out
		rotright ${1} 25; rotright__c=$rotright__out
		ep1__out=$(( rotright__a ^ rotright__b ^ rotright__c ))
	}
	function sig0 {
		rotright ${1} 7; rotright__a=$rotright__out
		rotright ${1} 18; rotright__b=$rotright__out
		sig0__out=$(( rotright__a ^ rotright__b ^ (${1} >> 3) ))
	}
	function sig1 {
		rotright ${1} 17; rotright__a=$rotright__out
		rotright ${1} 19; rotright__b=$rotright__out
		sig1__out=$(( rotright__a ^ rotright__b ^ (${1} >> 10) ))
	}
	function b32 {
		b32__out=$(( ${1} & 0xFFFFFFFF ))
	}
	function not32 {
		b32 $(( ~${1} ))
		not32__out=$b32__out
	}
	
	function sha256_transform {
		local -a m=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
		for i in {0..15}; do
			local j=$((i * 4))
			b32 $(( (data[j] << 24) | (data[j+1] << 16) | (data[j+2] << 8) | data[j+3] ))
			m[i]=$b32__out
		done
		for i in {16..63}; do
			sig0 ${m[i-15]}
			sig1 ${m[i-2]}
			b32 $(( sig1__out + m[i-7] + sig0__out + m[i-16] ))
			m[i]=$b32__out
		done

		local \
			a=${state[0]} \
			b=${state[1]} \
			c=${state[2]} \
			d=${state[3]} \
			e=${state[4]} \
			f=${state[5]} \
			g=${state[6]} \
			h=${state[7]}
	
		for i in {0..63}; do
			ep1 $e
			ch $e $f $g
			b32 $(( h + ep1__out + ch__out + k[i] + m[i] ))
			local t1=$b32__out

			maj $a $b $c
			ep0 $a
			b32 $(( ep0__out + maj__out ))
			local t2=$b32__out

			h=$g
			g=$f
			f=$e

			b32 $(( d + t1 ))
			e=$b32__out
			d=$c
			c=$b
			b=$a

			b32 $(( t1 + t2 ))
			a=$b32__out
		done
		b32 $(( state[0] + a ))	
		state[0]=$b32__out
		b32 $(( state[1] + b ))
		state[1]=$b32__out
		b32 $(( state[2] + c ))
		state[2]=$b32__out
		b32 $(( state[3] + d ))
		state[3]=$b32__out
		b32 $(( state[4] + e ))
		state[4]=$b32__out
		b32 $(( state[5] + f ))
		state[5]=$b32__out
		b32 $(( state[6] + g ))
		state[6]=$b32__out
		b32 $(( state[7] + h ))
		state[7]=$b32__out

	}
	
	while read line; do
		for byte in $line; do
			data[datalen]=$byte
			datalen=$(( datalen + 1 ))
			if [[ $datalen == 64 ]]; then
				sha256_transform
				dbl_int_add 512
				datalen=0
			fi
		done
	done < <(od -An -t d1)
	
	local i=$datalen
	
	if [[ $datalen < 56 ]]; then
		data[i]=$(( 0x80 ))
		i=$(( i + 1 ))
		while [[ $i < 56 ]]; do
			data[i]=0
			i=$(( i + 1 ))
		done
	else
		data[i]=$(( 0x80 ))
		i=$(( i + 1 ))
		while [[ $i < 64 ]]; do
			data[i]=0
			i=$(( i + 1 ))
		done
		sha256_transform
		for j in {0..55}; do
			data[j]=0
		done
	fi
	
	dbl_int_add $(( datalen * 8 ))
	data[63]=$(( bitlen[0] & 0xFF ))
	data[62]=$(( (bitlen[0] >> 8) & 0xFF ))
	data[61]=$(( (bitlen[0] >> 16) & 0xFF ))
	data[60]=$(( (bitlen[0] >> 24) & 0xFF ))
	data[59]=$(( bitlen[1] & 0xFF ))
	data[58]=$(( (bitlen[1] >> 8) & 0xFF ))
	data[57]=$(( (bitlen[1] >> 16) & 0xFF ))
	data[56]=$(( (bitlen[1] >> 24) & 0xFF ))
	sha256_transform
	
	for j in {0..3}; do
		rhash[j]=$(( (state[0] >> (24 - j * 8)) & 0xff ))
		rhash[j+4]=$(( (state[1] >> (24 - j * 8)) & 0xff ))
		rhash[j+8]=$(( (state[2] >> (24 - j * 8)) & 0xff ))
		rhash[j+12]=$(( (state[3] >> (24 - j * 8)) & 0xff ))
		rhash[j+16]=$(( (state[4] >> (24 - j * 8)) & 0xff ))
		rhash[j+20]=$(( (state[5] >> (24 - j * 8)) & 0xff ))
		rhash[j+24]=$(( (state[6] >> (24 - j * 8)) & 0xff ))
		rhash[j+28]=$(( (state[7] >> (24 - j * 8)) & 0xff ))
	done
	
	printf "%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x\n" ${rhash[@]}
}

# If not sourced, call main function
[[ ${BASH_SOURCE[0]} == "${0}" ]] && sha256sum.bash



