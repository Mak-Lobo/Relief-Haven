import {BrowserRouter, Routes, Route, Navigate} from 'react-router-dom';
import {Login} from './pages/authentication/Login';
import Registration from './pages/authentication/Registration'; // ✅ uncommented + correct name
import Skeleton from './pages/common/Skeleton.jsx';

function App() {
    return (
        <BrowserRouter>
            <Routes>
                <Route path="/login" element={<Login/>}/>
                <Route path="/register" element={<Registration/>}/> {/* ✅ Registration, not Register */}
                <Route path="/" element={<Skeleton/>}/>
            </Routes>
        </BrowserRouter>
    );
}

export default App;