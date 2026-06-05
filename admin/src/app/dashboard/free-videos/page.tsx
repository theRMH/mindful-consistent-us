'use client';

import { useState, useEffect } from 'react';

interface FreeVideo {
  id: string;
  title: string;
  description: string | null;
  category: string | null;
  durationSeconds: number;
  bunnyVideoId: string;
  bunnyLibraryId: string;
  sortOrder: number;
  isPublished: boolean;
  createdAt: string;
}

export default function FreeVideosPage() {
  const [videos, setVideos] = useState<FreeVideo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  // Form states
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalMode, setModalMode] = useState<'add' | 'edit'>('add');
  const [selectedVideo, setSelectedVideo] = useState<FreeVideo | null>(null);

  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [category, setCategory] = useState('general');
  const [durationSeconds, setDurationSeconds] = useState('120');
  const [bunnyVideoId, setBunnyVideoId] = useState('');
  const [bunnyLibraryId, setBunnyLibraryId] = useState('mock_lib_123');
  const [sortOrder, setSortOrder] = useState('0');
  const [isPublished, setIsPublished] = useState(true);
  const [submitLoading, setSubmitLoading] = useState(false);

  // Delete states
  const [videoToDelete, setVideoToDelete] = useState<FreeVideo | null>(null);

  const fetchVideos = async () => {
    try {
      const res = await fetch('/api/videos/free?all=true');
      if (!res.ok) throw new Error('Failed to fetch free videos');
      const data = await res.json();
      setVideos(data);
      setLoading(false);
    } catch (err: any) {
      setError(err.message || 'Something went wrong');
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchVideos();
  }, []);

  const openAddModal = () => {
    setModalMode('add');
    setSelectedVideo(null);
    setTitle('');
    setDescription('');
    setCategory('general');
    setDurationSeconds('120');
    setBunnyVideoId('');
    setBunnyLibraryId('mock_lib_123');
    setSortOrder('0');
    setIsPublished(true);
    setError('');
    setIsModalOpen(true);
  };

  const openEditModal = (video: FreeVideo) => {
    setModalMode('edit');
    setSelectedVideo(video);
    setTitle(video.title);
    setDescription(video.description || '');
    setCategory(video.category || 'general');
    setDurationSeconds(video.durationSeconds.toString());
    setBunnyVideoId(video.bunnyVideoId);
    setBunnyLibraryId(video.bunnyLibraryId);
    setSortOrder(video.sortOrder.toString());
    setIsPublished(video.isPublished);
    setError('');
    setIsModalOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSubmitLoading(true);

    const payload = {
      title,
      description,
      category,
      durationSeconds,
      bunnyVideoId,
      bunnyLibraryId,
      sortOrder,
      isPublished,
    };

    try {
      let res;
      if (modalMode === 'add') {
        res = await fetch('/api/videos/free', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload),
        });
      } else {
        res = await fetch(`/api/videos/free/${selectedVideo?.id}`, {
          method: 'PATCH',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload),
        });
      }

      if (!res.ok) {
        const errorData = await res.json();
        throw new Error(errorData.error || 'Failed to save free video');
      }

      setIsModalOpen(false);
      fetchVideos();
    } catch (err: any) {
      setError(err.message || 'Error saving video');
    } finally {
      setSubmitLoading(false);
    }
  };

  const handleDelete = async () => {
    if (!videoToDelete) return;
    setError('');
    try {
      const res = await fetch(`/api/videos/free/${videoToDelete.id}`, {
        method: 'DELETE',
      });
      if (!res.ok) throw new Error('Failed to delete video');
      setVideoToDelete(null);
      fetchVideos();
    } catch (err: any) {
      setError(err.message || 'Error deleting video');
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-2xl font-extrabold text-gray-900">Free Preview Videos</h2>
          <p className="text-sm text-gray-500 mt-1">Manage guest-accessible tutorial content, trailers, and preview clips.</p>
        </div>
        <button
          onClick={openAddModal}
          className="inline-flex items-center px-4 py-2.5 border border-transparent text-sm font-bold rounded-lg text-white bg-emerald-600 hover:bg-emerald-700 transition-colors shadow-sm"
        >
          <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
          </svg>
          Add Free Video
        </button>
      </div>

      {error && (
        <div className="bg-red-50 text-red-600 p-4 rounded-lg border border-red-100 font-medium text-sm">
          {error}
        </div>
      )}

      {loading ? (
        <div className="h-64 flex items-center justify-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600"></div>
        </div>
      ) : videos.length === 0 ? (
        <div className="bg-white shadow rounded-lg border border-gray-100 p-20 text-center flex flex-col items-center">
          <svg className="w-16 h-16 text-gray-300 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 00-2 2z" />
          </svg>
          <p className="text-gray-500 font-bold">No free preview videos registered yet</p>
          <p className="text-sm text-gray-400 mt-1">Free videos are displayed directly to unregistered users on the app hub.</p>
        </div>
      ) : (
        <div className="bg-white shadow rounded-lg border border-gray-100 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-100">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Order</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Title</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Category</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Duration</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Bunny Video ID</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Status</th>
                  <th className="px-6 py-3 text-right text-xs font-bold text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-100">
                {videos.map((vid) => (
                  <tr key={vid.id} className="hover:bg-gray-50/50 transition-colors">
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 font-bold">
                      #{vid.sortOrder}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="font-bold text-gray-900">{vid.title}</div>
                      <div className="text-xs text-gray-400 max-w-xs truncate">{vid.description || 'No description'}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600 capitalize">
                      {vid.category}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 font-semibold">
                      {Math.floor(vid.durationSeconds / 60)}m {vid.durationSeconds % 60}s
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-xs text-slate-500 font-mono">
                      {vid.bunnyVideoId}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-bold rounded-full ${
                        vid.isPublished 
                          ? 'bg-emerald-50 text-emerald-700 border border-emerald-100' 
                          : 'bg-amber-50 text-amber-700 border border-amber-100'
                      }`}>
                        {vid.isPublished ? 'Published' : 'Draft'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-semibold space-x-3">
                      <button
                        onClick={() => openEditModal(vid)}
                        className="text-emerald-600 hover:text-emerald-700 hover:underline"
                      >
                        Edit
                      </button>
                      <button
                        onClick={() => setVideoToDelete(vid)}
                        className="text-red-600 hover:text-red-700 hover:underline"
                      >
                        Delete
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Edit/Add Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 overflow-y-auto">
          <div className="bg-white rounded-xl shadow-2xl max-w-lg w-full overflow-hidden border border-gray-100">
            <div className="px-6 py-4 bg-slate-900 text-white flex justify-between items-center">
              <h3 className="font-extrabold text-lg">{modalMode === 'add' ? 'Add Free Preview Video' : 'Edit Free Preview Video'}</h3>
              <button onClick={() => setIsModalOpen(false)} className="text-slate-400 hover:text-white transition-colors">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>

            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              <div>
                <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">Video Title</label>
                <input
                  type="text"
                  required
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-emerald-500 focus:border-emerald-500"
                  placeholder="e.g. Introduction to Hatha Yoga"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">Description</label>
                <textarea
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-emerald-500 focus:border-emerald-500"
                  rows={3}
                  placeholder="Describe this preview video..."
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">Category</label>
                  <input
                    type="text"
                    value={category}
                    onChange={(e) => setCategory(e.target.value)}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-emerald-500 focus:border-emerald-500"
                    placeholder="e.g. general, yoga"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">Duration (Seconds)</label>
                  <input
                    type="number"
                    required
                    value={durationSeconds}
                    onChange={(e) => setDurationSeconds(e.target.value)}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-emerald-500 focus:border-emerald-500"
                    min="1"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">Bunny Video ID</label>
                  <input
                    type="text"
                    required
                    value={bunnyVideoId}
                    onChange={(e) => setBunnyVideoId(e.target.value)}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-emerald-500 focus:border-emerald-500"
                    placeholder="e.g. a1b2c3d4-e5f6..."
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">Bunny Library ID</label>
                  <input
                    type="text"
                    required
                    value={bunnyLibraryId}
                    onChange={(e) => setBunnyLibraryId(e.target.value)}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-emerald-500 focus:border-emerald-500"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">Sort Order</label>
                  <input
                    type="number"
                    required
                    value={sortOrder}
                    onChange={(e) => setSortOrder(e.target.value)}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-emerald-500 focus:border-emerald-500"
                  />
                </div>
                <div className="flex items-center mt-6">
                  <input
                    id="isPublishedModal"
                    type="checkbox"
                    checked={isPublished}
                    onChange={(e) => setIsPublished(e.target.checked)}
                    className="h-4 w-4 text-emerald-600 border-gray-300 rounded focus:ring-emerald-500"
                  />
                  <label htmlFor="isPublishedModal" className="ml-2 block text-sm font-bold text-gray-900">
                    Publish immediately
                  </label>
                </div>
              </div>

              <div className="flex justify-end space-x-3 pt-4 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 border border-gray-300 rounded-lg text-sm font-bold text-gray-700 hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={submitLoading}
                  className="px-4 py-2 border border-transparent text-sm font-bold rounded-lg text-white bg-emerald-600 hover:bg-emerald-700 transition-colors shadow-sm"
                >
                  {submitLoading ? 'Saving...' : 'Save Video'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {videoToDelete && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50">
          <div className="bg-white rounded-xl shadow-2xl max-w-md w-full overflow-hidden border border-gray-100">
            <div className="p-6 text-center space-y-4">
              <div className="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-red-100 text-red-600">
                <svg className="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                </svg>
              </div>
              <div>
                <h3 className="text-lg font-bold text-gray-900">Delete Free Video</h3>
                <p className="text-sm text-gray-500 mt-2">
                  Are you sure you want to delete <span className="font-semibold text-gray-800">"{videoToDelete.title}"</span>? This action cannot be undone and will immediately remove the video from guest screens on the mobile app.
                </p>
              </div>
              <div className="flex justify-center space-x-3 pt-2">
                <button
                  onClick={() => setVideoToDelete(null)}
                  className="px-4 py-2 border border-gray-300 rounded-lg text-sm font-bold text-gray-700 hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleDelete}
                  className="px-4 py-2 border border-transparent text-sm font-bold rounded-lg text-white bg-red-600 hover:bg-red-700 transition-colors shadow-sm"
                >
                  Delete Video
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
