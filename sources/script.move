script {
    use aptos_token::token::{Self, TokenDataId};
    use std::string::{Self, String};
    use aptos_token::property_map;

    const ROYALTEE_PAYEE_ADDRESS: address = @0x4230ae221d653cc39b40140f11783a45b557fe560b21461dacbd46094bf1b7b3;
    const ROYALTY_POINTS_NUMERATOR: u64 = 8;
    const ROYALTY_POINTS_DENOMINATOR: u64 = 100;
    const SPECIAL_PROPERTY_NAME: vector<u8> = b"special";
    const COLLECTION_NAME: vector<u8> = b"Aptomingos";

    fun create_token_data(
        token_signer: &signer,
        token_name: String,x
        token_uri: String,
        special_property_value: &String,
    ): TokenDataId {
        // Set up the NFT
        let nft_maximum: u64 = 1;

        let collection_name = string::utf8(COLLECTION_NAME);
        // is this correct?
        let description = string::utf8(b"");

        // tokan max mutable: true
        // token URI mutable: true
        // token description mutable: true
        // token royalty mutable: true
        // token properties mutable: true
        let token_mutate_config = token::create_token_mutability_config(&vector<bool>[ true, true, true, true, true ]);

        let special_name = string::utf8(SPECIAL_PROPERTY_NAME);
        let special_value = property_map::create_property_value(special_property_value);

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
        collection_address: address,

    ) {
        // TODO: Ensure current supply max is `amount_from` for idempotency
        // Also, this doesn't exist yet
        let current_max = token::get_collection_maximum(collection_address, collection_name);
        assert(current_max == amount_from, 126);
        // Also, this doesn't exist yet
        token::mutate_collection_maximum(token_signer, collection_address, collection_name, amount_to);
    }

    fun main(script_runner: &signer) {
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

        assert!(std::vector::length(&token_names) == std::vector::length(&token_uris), 1);

        // TODO: whatever this is
        let token_signer: signer = some_contract::get_token_signer(script_runner);

        increase_collection_supply(1212, 1222);

        while (!std::vector::is_empty(&token_names)) {
            let token_name = std::string::utf8(std::vector::pop_back(&mut token_names));
            let token_uri = std::string::utf8(std::vector::pop_back(&mut token_uris));

            // Create the TokenData + mint the token
            let tokendata_id = create_token_data(
                &token_signer,
                token_name,
                token_uri,
                token_name, //special_property_value: &String,
            );
            let token_id = token::mint_token(&token_signer, tokendata_id, 1);

            // Move token to script runners account
            let token = token::withdraw_token(&token_signer, token_id, 1);
            token::deposit_token(script_runner, token);
        }
    }
}