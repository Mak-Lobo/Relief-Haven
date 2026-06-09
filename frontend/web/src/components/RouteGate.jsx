import {Navigate} from "react-router-dom";
import Skeleton from "../pages/common/Skeleton.jsx";
import {useAuth} from "../context/AuthContext.jsx";

export const RouteGate = () => {
    const {user, loading} = useAuth();

    if (loading) return null;
    return user ? <Skeleton/> : <Navigate to="/login" replace />;
};

export const PublicGate = ({children}) => {
    const {user, loading} = useAuth();

    if (loading) return null;
    return user ? <Navigate to="/" replace /> : children;
};
