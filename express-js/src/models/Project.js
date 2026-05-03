import mongoose from 'mongoose';

const projectSchema = new mongoose.Schema(
    {
        title: {
            type: String,
            required: [true, 'Le titre est obligatoire'],
            trim: true,
            maxlength: [200, 'Le titre ne peut pas dépasser 200 caractères']
        },
        shortDescription: {
            type: String,
            trim: true,
            maxlength: [300, 'La description courte ne peut pas dépasser 300 caractères']
        },
        description: {
            type: String,
            required: [true, 'La description est obligatoire'],
            trim: true
        },
        image: {
            type: String,
            trim: true,
            default: function() {
                return `https://placehold.co/600x400/1e3a5f/white?text=${encodeURIComponent(this.title)}`;
            }
        },
        technologies: {
            type: [String],
            required: [true, 'Au moins une technologie est requise'],
            validate: {
                validator: function(arr) {
                    return arr && arr.length > 0;
                },
                message: 'Au moins une technologie est requise'
            }
        },
        demoUrl: {
            type: String,
            trim: true,
            default: '#'
        },
        githubUrl: {
            type: String,
            trim: true,
            default: '#'
        }
    },
    {
        timestamps: true,
        toJSON: { virtuals: true },
        toObject: { virtuals: true }
    }
);

projectSchema.index({ title: 'text', description: 'text' });

projectSchema.virtual('summary').get(function() {
    return this.shortDescription || this.description.substring(0, 150) + '...';
});

const Project = mongoose.model('Project', projectSchema);

export default Project;
