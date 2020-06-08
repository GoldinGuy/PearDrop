use argh::FromArgs;
use rand::prelude::*;
use peardrop_protocol::*;
use std::{fs, net};

const UDP_MULTICAST_ADDRESS: net::Ipv4Addr = net::Ipv4Addr::new(224, 0, 0, 3);
const UDP_MULTICAST_PORT: u16 = 65535;
const INADDR_ANY: net::Ipv4Addr = net::Ipv4Addr::new(0, 0, 0, 0);

#[derive(FromArgs)]
/// Send a file to a receiver using PearDrop.
struct PearDropOpts {
    /// name of the file to send
    #[argh(positional)]
    filename: String,
}

/// Ask a yes/no question to the user.
macro_rules! ask {
    ($($a:expr),*) => {{
        print!($($a),*);
        use std::io::Write;
        std::io::stdout().flush().unwrap();
        let mut s = String::new();
        std::io::stdin().read_line(&mut s).unwrap();
        s.trim() == "y"
    }};
}

fn main() -> std::io::Result<()> {
    let args: PearDropOpts = argh::from_env();
    let self_port = random::<u16>() + 1025;
    let self_udp_addr = net::SocketAddrV4::new(INADDR_ANY, self_port);
    let self_tcp_addr = net::SocketAddrV4::new(INADDR_ANY, self_port);

    {
        println!("Binding UDP socket (ephmeral)");
        // UDP step
        let sock = net::UdpSocket::bind(self_udp_addr)?;
        sock.set_broadcast(true)?;

        // Send ad packet to multicast
        let out = {
            let ad_packet = AdPacket::new(AdExtensions {
                tcp: Some(TCPAdExtension { ad_port: self_port }),
            });
            let mut out = Vec::new();
            ad_packet.write(&mut out).unwrap();
            out
        };

        sock.send_to(
            &out,
            net::SocketAddrV4::new(UDP_MULTICAST_ADDRESS, UDP_MULTICAST_PORT),
        )?;
        println!("Broadcasted on UDP multicast");
    }

    // TCP step
    let sock = net::TcpListener::bind(self_tcp_addr)?;

    for stream in sock.incoming() {
        let mut stream = stream?;
        println!("Accepted TCP receiver");
        // Read ack packet
        let packet = AckPacket::read(&mut stream).expect("Malformed packet from receiver");
        println!("Read ack packet");
        // If accept, then ask user if they want to send
        if let Some(true) = packet.get_type().is_accepted() {
            println!("Received accept ack");
            let peer_addr = stream.peer_addr()?;
            // Try to get other port, otherwise reject
            let other_port = if let Some(TCPAckExtension { ad_port: port }) = packet.extensions.tcp
            {
                port
            } else {
                println!("Couldn't find TCP extension, skipping");
                continue;
            };
            let should_send = ask!(
                "Should we send to this receiver (addr={})? [y/n] ",
                peer_addr
            );
            if should_send {
                println!("Attempting to connect");
                // Negotiate the rest of the handshake.
                let addr = net::SocketAddr::new(peer_addr.ip(), other_port);
                let mut connection = net::TcpStream::connect(addr)?;
                println!("Connected to receiver");
                let mut f = fs::File::open(&args.filename)?;
                let data_len = f.metadata()?.len();

                let packet = SenderPacket::new(
                    args.filename.clone(),
                    "text/plain".to_string(),
                    Vec::new(),
                    data_len,
                );
                packet
                    .write(&mut connection)
                    .expect("Could not write packet to receiver");
                println!("Sent sender packet");
                // Try to receive ack to the packet, and if rejected, bail out.
                let ackp =
                    AckPacket::read(&mut connection).expect("Malformed packet from receiver");
                println!("Recieved ack packet");
                match ackp.get_type().is_accepted() {
                    Some(true) => {}
                    _ => {
                        println!("Receiver rejected send.");
                        break;
                    }
                }
                // continue, send data
                use std::io::Read;
                std::io::copy(&mut (&mut f).take(data_len), &mut connection)?;
                println!("Written data");
                // Wait for ack and succeed!
                let ackp =
                    AckPacket::read(&mut connection).expect("Malformed packet from receiver");
                match ackp.get_type().get_type() {
                    AckTypeType::DataPacket => {
                        println!("Woohoo! Transfer complete");
                        break;
                    }
                    _ => {
                        println!("Ummm... Ack wasn't right? Quitting anyways");
                        break;
                    }
                }
            }
        }
    }

    Ok(())
}
