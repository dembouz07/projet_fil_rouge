import mongoose from 'mongoose';

const connectDB = async () => {
    try {
        const conn = await mongoose.connect(process.env.MONGODlB_URI);
        console.log('MongoDB connecte:', conn.connection.host);
        console.log('Base de donnees:', conn.connection.name);
    } catch (error) {
        console.error('Erreur de connexion MongoDB:', error.message);
        process.exit(1);
    }
};

mongoose.connection.on('disconnected', () => {
    console.log('MongoDB deconnecte');
});

mongoose.connection.on('error', (err) => {
    console.error('Erreur MongoDB:', err);
});

export default connectDB;
