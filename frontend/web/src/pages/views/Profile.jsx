import {MdEdit, MdLogout} from "react-icons/md";
import {useNavigate} from "react-router-dom";
import common from "../../styles/views-common.module.css";
import styles from "../../styles/profile.module.css";
import {useAuth} from "../../context/AuthContext.jsx";

const Profile = () => {
    const {signOut, user, profile} = useAuth();
    const navigate = useNavigate();

    const handleLogout = async () => {
        await signOut();
        navigate("/login");
    };

    // Build profile fields from user data
    const profileFields = profile ? [
        {label: "First Name", value: profile.first_name || "N/A"},
        {label: "Last Name", value: profile.last_name || "N/A"},
        // eslint-disable-next-line no-constant-binary-expression
        {label: "Phone number", value: `+254${profile.phone}` || "N/A"},
        {
            label: "Role",
            value: profile.role_user ? `${profile.role_user.charAt(0).toUpperCase()}${profile.role_user.slice(1).toLowerCase()}` : "N/A"
        },
        ...(profile.role_user === 'manager' ? [
            {
                label: "County of work",
                value: profile.county_work ? `${profile.county_work.charAt(0).toUpperCase()}${profile.county_work.slice(1).toLowerCase()}` : "N/A"
            }
        ] : []),
        {label: "Email Address", value: user?.email || "N/A"},
        {
            label: "Created at",
            value: profile.created_at ? new Date(profile.created_at).toLocaleDateString("en-GB", {
                day: "numeric",
                month: "short",
                year: "numeric"
            }) : "N/A"
        },
        {
            label: "Updated at",
            value: profile.updated_at ? new Date(profile.updated_at).toLocaleDateString("en-GB", {
                day: "numeric",
                month: "short",
                year: "numeric"
            }) : "N/A"
        },
    ] : [
        {label: "First Name", value: "Mark"},
        {label: "Last Name", value: "Njoroge"},
        {label: "Phone number", value: "+2547200177"},
        {label: "Role", value: "Manager - Muranga"},
        {label: "Email Address", value: user?.email || "markknjoroge@reliefhaven.ac.ke"},
        {label: "Created at", value: "4 Mar, 2025"},
        {label: "Updated at", value: "12 Dec, 2026"},
    ];

    return (
        <div className={common.pageFrame}>
            <div className={styles.profileOuter}>
                <h1 className={common.pageTitleCentered}>Account Profile</h1>

                <div className={styles.profileCard}>
                    <div className={styles.profileGrid}>
                        {profileFields.map((field) => (
                            <div key={field.label} className={styles.profileField}>
                                <span className={common.fieldLabel}>{field.label}</span>
                                <span className={styles.fieldValue}>{field.value}</span>
                            </div>
                        ))}
                    </div>

                    <div className={common.actionRowCentered}>
                        <button className={common.primaryAction} type="button" onClick={() => navigate("/profile/edit")}>
                            <MdEdit/>
                            <span>Edit Profile</span>
                        </button>
                        <button className={common.dangerAction} type="button" onClick={handleLogout}>
                            <MdLogout/>
                            <span>Logout</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Profile;
