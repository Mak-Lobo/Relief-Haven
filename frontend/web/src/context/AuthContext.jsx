import {createContext, useContext, useState, useEffect} from "react";
import {createClient} from "@supabase/supabase-js";
import {signInUser as signInService, signOutUser as signOutService} from "../services/auth/SignIn";

const supabase = createClient(
    import.meta.env.VITE_SUPABASE_URL,
    import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY
);

const AuthContext = createContext(null);

const STORAGE_KEY = "relief_haven_auth";

// Backend API base URL
const API_URL = import.meta.env.VITE_BACKEND_URL;

export function AuthProvider({children}) {
    const [user, setUser] = useState(null);
    const [profile, setProfile] = useState(null);
    const [loading, setLoading] = useState(true);

    // Restore session from localStorage on mount
    useEffect(() => {
        const stored = localStorage.getItem(STORAGE_KEY);
        if (stored) {
            try {
                const parsed = JSON.parse(stored);
                setUser(parsed);
                // Use the same UUID stored from login/registration
                fetchProfile(parsed.id, parsed.token);
            } catch {
                localStorage.removeItem(STORAGE_KEY);
            }
        }
        setLoading(false);
    }, []);

    // Fetch user profile from backend using the Supabase UUID (same as in DB)
    const fetchProfile = async (userId, token) => {
        try {
            const response = await fetch(`${API_URL}/users/${userId}`, {
                headers: {
                    "Authorization": `Bearer ${token}`
                }
            });
            if (response.ok) {
                const data = await response.json();
                setProfile(data);
            }
        } catch (error) {
            console.error("Failed to fetch profile:", error);
        }
    };

    const signIn = async ({email, password}) => {
        const result = await signInService({email, password});
        if (result.success) {
            const userData = {
                id: result.user.id,
                email: result.user.email,
                token: result.token
            };
            setUser(userData);
            localStorage.setItem(STORAGE_KEY, JSON.stringify(userData));
            // Fetch profile using the same Supabase UUID
            await fetchProfile(result.user.id, result.token);
        }
        return result;
    };

    const signOut = async () => {
        await signOutService();
        setUser(null);
        setProfile(null);
        localStorage.removeItem(STORAGE_KEY);
    };

    return (
        <AuthContext.Provider value={{user, profile, loading, signIn, signOut, fetchProfile}}>
            {children}
        </AuthContext.Provider>
    );
}

export function useAuth() {
    const context = useContext(AuthContext);
    if (!context) {
        throw new Error("useAuth must be used within AuthProvider");
    }
    return context;
}