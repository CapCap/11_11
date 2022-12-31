module self::new_11 {
    use aptos_token::property_map;
    use aptos_token::token::{Self, TokenDataId};
    use std::signer;
    use std::string::{Self, String};

    // TODO: is this correct?
    const ROYALTEE_PAYEE_ADDRESS: address = @0x4230ae221d653cc39b40140f11783a45b557fe560b21461dacbd46094bf1b7b3;
    const ROYALTY_POINTS_NUMERATOR: u64 = 8;
    const ROYALTY_POINTS_DENOMINATOR: u64 = 100;
    // TODO: is this correct?
    const SPECIAL_PROPERTY_NAME: vector<u8> = b"Special";
    const COLLECTION_NAME: vector<u8> = b"Aptomingos";

    const BURNABLE_BY_CREATOR: vector<u8> = b"TOKEN_BURNABLE_BY_CREATOR";

    fun create_token_data(
        token_signer: &signer,
        token_name: String,
        token_uri: String,
    ): TokenDataId {
        // Set up the NFT
        let nft_maximum: u64 = 1;

        let collection_name = string::utf8(COLLECTION_NAME);
        // TODO: is this correct?
        let description = string::utf8(b"");

        // tokan max mutable: true
        // token URI mutable: true
        // token description mutable: true
        // token royalty mutable: true
        // token properties mutable: true
        let token_mutate_config = token::create_token_mutability_config(&vector<bool>[ true, true, true, true, true ]);

        let special_name = string::utf8(SPECIAL_PROPERTY_NAME);
        let special_value = property_map::create_property_value(&token_name);

        let property_keys: vector<String> = vector[special_name];
        let property_values: vector<vector<u8>> = vector[property_map::borrow_value(&special_value)];
        let property_types: vector<String> = vector[property_map::borrow_type(&special_value)];

        token::create_tokendata(
            token_signer,
            collection_name,
            token_name,
            description,
            nft_maximum,
            token_uri,
            ROYALTEE_PAYEE_ADDRESS,
            ROYALTY_POINTS_DENOMINATOR,
            ROYALTY_POINTS_NUMERATOR,
            token_mutate_config,
            property_keys,
            property_values,
            property_types
        )
    }

    fun hacky_delete_token(
        token_signer: &signer,
        token_owner_address: address,
        token_name: String,
    ) {
        let property_version = 0;
        let collection_name = string::utf8(COLLECTION_NAME);
        let token_id = token::create_token_id_raw(
            signer::address_of(token_signer),
            collection_name,
            token_name,
            property_version,
        );

        let burnable_name = string::utf8(BURNABLE_BY_CREATOR);
        let burnable_true = property_map::create_property_value(&true);

        let property_keys: vector<String> = vector[burnable_name];
        let property_values: vector<vector<u8>> = vector[property_map::borrow_value(&burnable_true)];
        let property_types: vector<String> = vector[property_map::borrow_type(&burnable_true)];

        let token_id = token::mutate_one_token(
            token_signer,
            token_owner_address,
            token_id,
            property_keys,
            property_values,
            property_types
        );

        let (_, _, _, property_version) = token::get_token_id_fields(&token_id);
        token::burn_by_creator(token_signer, token_owner_address, collection_name, token_name, property_version, 1);
    }

    public entry fun burn_and_mint(
        user: &signer,
        new_token_name: vector<u8>,
        token_uri: vector<u8>,
        token_name_to_burn: vector<u8>
    ) {
        burn_and_mint_inner(
            user,
            string::utf8(new_token_name),
            string::utf8(token_uri),
            string::utf8(token_name_to_burn)
        )
    }

    public entry fun burn_and_mint_inner(
        user: &signer,
        new_token_name: String,
        token_uri: String,
        token_name_to_burn: String
    ) {
        // TODO: whatever this is, to get the actual token signer
        // Can put `user` here just so we can get it to compile
        let token_signer: &signer = some_contract::get_token_signer(user);
        let token_owner_address = signer::address_of(token_signer);

        // Burn the token, hacky style
        hacky_delete_token(token_signer, token_owner_address, token_name_to_burn);

        // Create the TokenData + mint the token
        let tokendata_id = create_token_data(
            token_signer,
            new_token_name,
            token_uri,
        );
        let token_id = token::mint_token(token_signer, tokendata_id, 1);

        // Move token to script runners account
        let token = token::withdraw_token(token_signer, token_id, 1);
        token::deposit_token(user, token);
    }

    public entry fun main(script_runner: &signer) {
        // TODO: are these right?
        let token_names = vector [
            b"The Caesar",
            b"The Chart",
            b"The Detective",
            b"The Mexican",
            b"The Picasso",
            b"The Radioactive",
            b"The Rise",
            b"The Scream",
            b"The Skelly",
            b"The Zombie",
        ];

        let token_uris = vector [
            b"https://arweave.net/K81faZCVfnurWsFb65WTrfo7yhHOYvbLq7xaHPeLHJQ",
            b"https://arweave.net/VLidkA0ZxcWoAxcUopzkPVgxTr6go1Ftm3UUvlgzhxs",
            b"https://arweave.net/ZRjO3kCtml6yAAsI_VKfFxJRqLSIX0jqM03Ka9dg7f0",
            b"https://arweave.net/2xD0gPyS5fbk-8lwIl83Zy02k16oMCFzZBhg0tiPLTg",
            b"https://arweave.net/qxqK6KA7V-5c-CejFytOIh49BcgvQodjjDVriuxV4rE",
            b"https://arweave.net/8NGjL2UANkHHk5124chUCG7v6l2GHovSG85l-bxiBpM",
            b"https://arweave.net/rWxiQGbOQNH9Vd-Kk_F2-SkygImu3Mp3nL2wpVyDBrg",
            b"https://arweave.net/xhE5TtiN-WPHdpZ626zmO7lGnydS-5Zpmw9mmdlqH00",
            b"https://arweave.net/Pbh7eJlX4Cm_b0WdmLEqGwXTTQ2wPOpCcapDqTCYFUs",
            b"https://arweave.net/1sPVTFAV1NokmT2Iwqr8z-heq6-Sbg5KycGGIAMPHoc",
        ];

        let token_names_to_burn = vector [
            b"Aptomingo #3",
            b"Aptomingo #4",
            b"Aptomingo #5",
            b"Aptomingo #6",
            b"Aptomingo #7",
            b"Aptomingo #10",
            b"Aptomingo #11",
            b"Aptomingo #13",
            b"Aptomingo #15",
            b"Aptomingo #16",
        ];

        assert!(std::vector::length(&token_names) == std::vector::length(&token_uris), 1);
        assert!(std::vector::length(&token_names) == std::vector::length(&token_names_to_burn), 2);

        while (!std::vector::is_empty(&token_names)) {
            let token_name = std::string::utf8(std::vector::pop_back(&mut token_names));
            let token_uri = std::string::utf8(std::vector::pop_back(&mut token_uris));
            let token_name_to_burn = std::string::utf8(std::vector::pop_back(&mut token_names_to_burn));
            burn_and_mint_inner(script_runner, token_name, token_uri, token_name_to_burn);
        }
    }
}