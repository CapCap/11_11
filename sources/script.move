script {
    use aptos_token::token;
    use std::string::{Self, String};
    use aptos_token::property_map;
    use std::signer;

    // TODO: is this correct?
    const ROYALTEE_PAYEE_ADDRESS: address = @0x4230ae221d653cc39b40140f11783a45b557fe560b21461dacbd46094bf1b7b3;
    const ROYALTY_POINTS_NUMERATOR: u64 = 8;
    const ROYALTY_POINTS_DENOMINATOR: u64 = 100;
    // TODO: is this correct?
    const SPECIAL_PROPERTY_NAME: vector<u8> = b"special";
    const COLLECTION_NAME: vector<u8> = b"Aptomingos";

    const BURNABLE_BY_CREATOR: vector<u8> = b"TOKEN_BURNABLE_BY_CREATOR";


    fun main(script_runner: &signer) {
        // TODO: are these right?
        let token_names = vector [
            b"the caesar",
            b"the chart",
            b"the detective",
            b"the mexican",
            b"the picasso",
            b"the radioactive",
            b"the rise",
            b"the scream",
            b"the skelly",
            b"the zombie",
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
            b"Aptomingo #4",
        ];

        assert!(std::vector::length(&token_names) == std::vector::length(&token_uris), 1);
        assert!(std::vector::length(&token_names) == std::vector::length(&token_names_to_burn), 2);

        // TODO: whatever this is, to get the actual token signer
        // Can put `script_runner` here just so we can get it to compile
        let token_signer: &signer = some_contract::get_token_signer(script_runner);

        let token_owner_address = signer::address_of(script_runner);

        let nft_maximum: u64 = 1;

        let collection_name = string::utf8(COLLECTION_NAME);
        let description = string::utf8(b"");
        let burnable_name = string::utf8(BURNABLE_BY_CREATOR);
        let burnable_true = property_map::create_property_value(&true);
        let special_name = string::utf8(SPECIAL_PROPERTY_NAME);

        while (!std::vector::is_empty(&token_names)) {
            let token_name = std::string::utf8(std::vector::pop_back(&mut token_names));
            let token_uri = std::string::utf8(std::vector::pop_back(&mut token_uris));
            let token_name_to_burn = std::string::utf8(std::vector::pop_back(&mut token_names_to_burn));

            // Burn the token, hacky style
            // Burn the token, hacky style
            // Burn the token, hacky style
            let property_version = 0;

            let token_id = token::create_token_id_raw(
                signer::address_of(token_signer),
                collection_name,
                token_name,
                property_version,
            );


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
            token::burn_by_creator(
                token_signer,
                token_owner_address,
                collection_name,
                token_name_to_burn,
                property_version,
                1
            );

            // End burn logic
            // End burn logic
            // End burn logic

            // Create the TokenData + mint the token
            // Create the TokenData + mint the token
            // Create the TokenData + mint the token
            // Set up the NFT

            // TODO: is this correct?

            // tokan max mutable: true
            // token URI mutable: true
            // token description mutable: true
            // token royalty mutable: true
            // token properties mutable: true
            let token_mutate_config = token::create_token_mutability_config(
                &vector<bool>[ true, true, true, true, true ]
            );

            let special_value = property_map::create_property_value(&token_name);

            let property_keys: vector<String> = vector[special_name];
            let property_values: vector<vector<u8>> = vector[property_map::borrow_value(&special_value)];
            let property_types: vector<String> = vector[property_map::borrow_type(&special_value)];

            let tokendata_id = token::create_tokendata(
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
            );

            let token_id = token::mint_token(token_signer, tokendata_id, 1);

            // End token data creation
            // End token data creation
            // End token data creation

            // Move token to script runners account
            let token = token::withdraw_token(token_signer, token_id, 1);
            token::deposit_token(script_runner, token);
        }
    }
}