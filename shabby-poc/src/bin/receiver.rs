use argh::FromArgs;
use shabby_poc::*;
use std::{fs, net};

const UDP_MULTICAST_ADDRESS: net::Ipv4Addr = net::Ipv4Addr::new(224, 0, 0, 3);
const INADDR_ANY: net::Ipv4Addr = net::Ipv4Addr::new(0, 0, 0, 0);

#[derive(FromArgs)]
/// Receive a file from a sender using PearDrop.
struct PearDropOpts {
    /// which TCP port we should use
    #[argh(option)]
    self_port: u16,

    /// which TCP port the sender is using
    #[argh(option)]
    other_port: u16,

    /// filename to save as
    #[argh(option, short = 'o')]
    out: String,
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
    let self_udp_addr = net::SocketAddrV4::new(UDP_MULTICAST_ADDRESS, args.other_port);
    let self_tcp_addr = net::SocketAddrV4::new(INADDR_ANY, args.self_port);

    let other_tcp_addr = {
        println!("Binding UDP socket (ephmeral)");
        // UDP step
        let sock = net::UdpSocket::bind(self_udp_addr)?;
        sock.join_multicast_v4(&UDP_MULTICAST_ADDRESS, &INADDR_ANY)?;
        println!("Joined multicast");
        let mut msg = vec![0; 128];
        let (_, addr) = sock.recv_from(&mut msg)?;
        let mut cursor = std::io::Cursor::new(msg);
        let _packet = AdPacket::read(&mut cursor).expect("Malformed ad packet");
        println!("Received ad packet");
        net::SocketAddr::new(addr.ip(), args.other_port)
    };

    // TCP step (1)
    // Send ack packet to sender then open TCP server
    {
        let mut stream = net::TcpStream::connect(other_tcp_addr)?;
        println!("Connected to sender TCP");
        let ack_type = AckType::AcceptReject(AckTypeType::AdPacket, true);
        let packet = AckPacket::new(ack_type, Vec::new());
        packet
            .write(&mut stream)
            .expect("Could not write packet to sender");
        println!("Sent accept ack");
    }

    // TCP step (2)
    // Wait for sender to connect to us (?)
    // (quit after timeout not impl'd)
    let sock = net::TcpListener::bind(self_tcp_addr)?;
    println!("Listening on {}", sock.local_addr()?);

    let (mut stream, peer_addr) = sock.accept()?;
    println!("Accepted TCP sender");
    // Read sender packet
    // Then ask user if they want to receive
    let packet = SenderPacket::read(&mut stream).expect("Malformed packet from sender");
    println!("Read sender packet");
    let should_receive = ask!(
        "Should we receive from this sender (addr={}, filename={}, mimetype={}, len={})? [y/n] ",
        peer_addr,
        packet.get_filename(),
        packet.get_mimetype(),
        packet.get_data_len()
    );
    if should_receive {
        // Receive by acking with an accept
        let ackp = AckPacket::new(
            AckType::AcceptReject(AckTypeType::SenderPacket, true),
            Vec::new(),
        );
        ackp.write(&mut stream)
            .expect("Could not write packet to sender");
        println!("Send accept ack");
        // Read data and write to file
        use std::io::Read;
        let mut f = fs::File::create(args.out)?;
        std::io::copy(&mut (&mut stream).take(packet.get_data_len()), &mut f)?;
        // Send ack
        let ackp = AckPacket::new(AckType::Normal(AckTypeType::DataPacket), Vec::new());
        ackp.write(&mut stream)
            .expect("Could not write packet to sender");
        println!("Send data accept ack");
        println!("Wahoo! Transfer complete");
    } else {
        // Ack with a reject
        let ackp = AckPacket::new(
            AckType::AcceptReject(AckTypeType::SenderPacket, false),
            Vec::new(),
        );
        ackp.write(&mut stream)
            .expect("Could not write packet to sender");
        println!("Rejected send.");
    }

    Ok(())
}
