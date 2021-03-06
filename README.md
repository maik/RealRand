# RealRand - Generate real random numbers with Ruby.

Many of algorithms in cryptography depend on good random
numbers, i.e. random numbers that are "real" random and not just
generated by a so called pseudo-random generator.

You cannot create real random numbers using a computer and an
algorithm. Only nature creates real randomness (just take a look
around the next time you are surrounded by a group of people.).

Real randomness occurs in atmospheric noise, during radioactive
decay, or in a lava lamp. Fortunately, you do not have to listen to an
old radio the whole day or, even worse, deposit some uranium in your
living room and observe it with a Geiger-Müller tube. Other people do
so (in a slightly modified manner, of course) and they kindly make
their results public.

There are at least the following web sites, that offer real random
numbers for free:

* http://www.random.org - Real random numbers are generated from
atmospheric noise on this site.

* http://www.fourmilab.ch/hotbits - The HotBits generator creates
real random numbers by timing successive pairs of radioactive
decays detected by a Geiger-Müller tube interfaced to a computer.

* http://random.hd.org - "This system gathers its 'entropy' or
truly random noise from a number of sources, including local
processes, files and devices, Web page hits and remote Web sites."

All these real random numbers can be requested via different HTTP
interfaces that all look very similar. E.g. you can request a number
of random bytes from any of the web sites above.

This project encapsulates all these very similar but still different
HTTP interfaces and offers simple Ruby interfaces to get real random
numbers from all the web sites mentioned above.

# Installation

This library requires at least Ruby 1.8.x.

RealRand is available as a gem, so you can install it like this:

  gem install realrand

# Usage

Once RealRand is installed and your internet connection is up,
generating real random numbers is a piece of cake:

    require 'random/online'

    generator1 = RealRand::RandomOrg.new
    puts generator1.randbyte(5).join(",")
    puts generator1.randnum(100, 1, 6).join(",") # Roll the dice 100 times.

    generator2 = RealRand::FourmiLab.new
    puts generator2.randbyte(5).join(",")
    # randnum is not supported.

    generator3 = RealRand::EntropyPool.new
    puts generator3.randbyte(5).join(",")
    # randnum is not supported.

# Limitations

The following limits do apply to the different functions:

* RandomOrg#randnum(number = 100, min = 1, max = 100) - You can
request up to 10,000 random numbers ranging from -1,000,000,000 to
1,000,000,000 with this method. Of course, max has to be bigger
than min.

* RandomOrg#randbyte(number = 256) - You can request up to 16,384
random bytes with this method.

* FourmiLab#randbyte(number = 128) - You can request up to 2,048
random bytes with this method.

* EntropyPool#randbyte(number = 16, limit_result = true) - You can
request up to 256 random bytes with this method. If there is not
enough randomness left in the pool, the result will be limited by
default, i.e. you will get less bytes than requested. If
limit_result is set to false, then the rest will be generated
using a pseudo-random generator.

# Proxies

If you have to use a HTTP proxy, you can set it as follows:

    require 'random/online'

    generator1 = RealRand::RandomOrg.new
    generator1.proxy_host = 'your.proxy.here'
    generator1.proxy_port = 8080
    generator1.proxy_usr  = 'your.user.here'
    generator1.proxy_pwd  = 'secret'
    puts generator1.randbyte(5).join(",")
    puts generator1.randnum(100, 1, 6).join(",")  # Roll the dice 100 times.

# Important Note

All the services used in this library are offered for free by their
maintainers. So, PLEASE, have a look at their web sites and obey to
their rules, if you use their service.

Copyright © 2003 - 2015 by Maik Schmidt.
