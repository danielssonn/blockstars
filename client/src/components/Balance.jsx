// assets
import IMAGES from '../../images'

const Balance = (tokens) => {
  return (
    <div className="flex items-center justify-evenly py-8 px-2 rounded-lg bg-[#E5F3FF]/50">

      {/* balance card */}

      {[
        { title: 'Available Staking Tokens', balance: tokens.available, bg: 'bg-coins' },
        { title: 'Staked Tokens', balance: tokens.staked, bg: 'bg-tree' },
        { title: 'Reward Tokens', balance: 150, bg: 'bg-rocket' }
      ].map((n, i) =>
        <div key={i} className={`w-1/4 rounded-xl p-8 flex ${n.bg} bg-white bg-cover bg-no-repeat`}>
          <div className="text-left flex flex-col justify-center">
            <p className="text-[#383be2] font-light text-base mb-2">{n.title}</p>
            <div className="flex">
              <p className="font-bold text-transparent bg-clip-text bg-gradient-to-br from-[#3926AD] to-[#C367D6] text-3xl">{n.balance} <span className="text-[#383be2]/80 font-light text-sm"></span></p>
              {i === 2 &&
                <button className="px-3 py-1 text-sm font-semibold border text-[#383be2]/80 border-[#383be2] rounded-lg ml-4">Harvest</button>
              }

            </div>
          </div>
        </div>
      )}

      <div className="flex items-center justify-evenly w-1/6">

        {/* title */}
        <div className="text-right mr-1">
          <p className="text-4xl font-bold text-[#5841f0]">My</p>
          <p className="text-4xl font-bold text-[#5841f0]">Token</p>
          <p className="text-4xl font-bold text-[#5841f0]">Balance</p>
        </div>

        {/* profile lg */}

        {/* <div className="relative w-1/2 flex justify-center items-center">
          <img id="profile" src={IMAGES.face} alt="profile-image" className="w-4/5 z-10" />
          <img src={IMAGES.bg2} alt="profile-image" className="absolute w-[120%] h-[120%] z-5" />
        </div> */}

      </div>

    </div>
  )
}

export default Balance