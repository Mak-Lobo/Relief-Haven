import {createClient} from "@supabase/supabase-js";

const supabase = createClient(
    import.meta.env.VITE_SUPABASE_URL,
    import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY
);

export async function signInUser({email, password}) {
    const {data, error} = await supabase.auth.signInWithPassword({email, password});
    if (error) return {success: false, error: error.message}

    console.log('User with email ', email, ' logged in successfully.');
    return {
        success: true,
        user: data.user,
        token: data.session.access_token,  // JWT token
    };
}

export async function signOutUser() {
    await supabase.auth.signOut();
}
